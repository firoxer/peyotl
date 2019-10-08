local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local tile_kinds = {
   empty = "empty",
   wall = "wall"
}

-- Using math.ceil ensures that the jaggedness matches with the map's edges
local function carve_with_simplex_noise(level_config)
   local algo = level_config.generation_algorithm_settings
   local matrix = ds.Matrix.new()
   local random_offset = love.math.random(0, 1000)

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         matrix:set(ds.Point.new(x, y), tile_kinds.wall)
      end
   end

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         local modified_x =
            math.ceil(x / algo.a_noise_jaggedness)
            * algo.a_noise_jaggedness
            * algo.a_noise_density
            + random_offset
         local modified_y =
            math.ceil(y / algo.a_noise_jaggedness)
            * algo.a_noise_jaggedness
            * algo.a_noise_density
            + random_offset

         local noise = love.math.noise(modified_x, modified_y) -- Not affected by love.math.setRandomSeed

         if noise < algo.a_noise_threshold then
            local point = ds.Point.new(x, y)
            if matrix:has(point) then
               matrix:set(point, tile_kinds.empty)
            end
         end
      end
   end

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         local modified_x =
            math.ceil(x / algo.b_noise_jaggedness)
            * algo.b_noise_jaggedness
            * algo.b_noise_density
            + random_offset
         local modified_y =
            math.ceil(y / algo.b_noise_jaggedness)
            * algo.b_noise_jaggedness
            * algo.b_noise_density
            + random_offset

         local noise = love.math.noise(modified_x, modified_y) -- Not affected by love.math.setRandomSeed
         if noise > algo.b_noise_threshold_low and noise < algo.b_noise_threshold_high then
            local point = ds.Point.new(x, y)
            if matrix:has(point) then
               matrix:set(point, tile_kinds.empty)
            end
         end
      end
   end

   return matrix
end

local function carve_with_random_squares(level_config)
   local algo = level_config.generation_algorithm_settings

   local matrix = ds.Matrix.new()

   local calculate_free_area = function()
      local wall_n = 0
      local empty_n = 0

      for _, tile_kind in matrix:pairs() do
         if tile_kind == tile_kinds.empty then
            empty_n = empty_n + 1
         else
            wall_n = wall_n + 1
         end
      end

      if wall_n == 0 and empty_n == 0 then
         error("matrix is empty")
      end

      return wall_n / (wall_n + empty_n)
   end

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         matrix:set(ds.Point.new(x, y), tile_kinds.empty)
      end
   end

   while calculate_free_area() < algo.minimum_wall_density do
      local random_nw_x = love.math.random(level_config.width)
      local random_nw_y = love.math.random(level_config.width)
      local square_size = love.math.random(algo.square_size_min, algo.square_size_max)
      local random_se_x = math.min(level_config.width, random_nw_x + square_size)
      local random_se_y = math.min(level_config.height, random_nw_y + square_size)

      for y = random_nw_y, random_se_y do
         for x = random_nw_x, random_se_x do
            matrix:set(ds.Point.new(x, y), tile_kinds.wall)
         end
      end
   end

   return matrix
end

local function carve_with_cellular_automatons(level_config)
   local algo = level_config.generation_algorithm_settings
   local matrix = ds.Matrix.new()

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         if love.math.random() < algo.initial_wall_chance then
            matrix:set(ds.Point.new(x, y), tile_kinds.wall)
         else
            matrix:set(ds.Point.new(x, y), tile_kinds.empty)
         end
      end
   end

   for _ = 1, algo.iterations do
      local updates = {}

      for y = 1, level_config.height do
         for x = 1, level_config.width do
            local point = ds.Point.new(x, y)
            local tile = matrix:get(point)

            local neighbors = matrix:get_immediate_neighbors(point)

            local alive_neighbors_n = 8
            for _, neighbor in pairs(neighbors) do
               if neighbor == tile_kinds.empty then
                  alive_neighbors_n = alive_neighbors_n - 1
               end
            end

            if tile == tile_kinds.empty then
               if alive_neighbors_n >= algo.birth_threshold then
                  table.insert(updates, function()
                     matrix:set(point, tile_kinds.wall)
                  end)
               end
            else
               if alive_neighbors_n < algo.survival_threshold then
                  table.insert(updates, function()
                     matrix:set(point, tile_kinds.empty)
                  end)
               end
            end
         end
      end

      for _, update in ipairs(updates) do
         update()
      end
   end

   return matrix
end

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      local matrix
      if level_config.generation_algorithm == "simplex" then
         matrix = carve_with_simplex_noise(level_config)
      elseif level_config.generation_algorithm == "random_squares" then
         matrix = carve_with_random_squares(level_config)
      elseif level_config.generation_algorithm == "cellular_automatons" then
         matrix = carve_with_cellular_automatons(level_config)
      else
         error("unknown map generation algorithm: " .. level_config.generation_algorithm)
      end
      for point, tile_kind in matrix:pairs() do
         local tileset_quad_name
         if tile_kind == tile_kinds.wall then
            if level_name == "aboveground" then
               tileset_quad_name = "aboveground_wall"
            else
               tileset_quad_name = "underground_wall"
            end
         else
            if level_name == "aboveground" then
               tileset_quad_name = table.sample({
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty2,
               })
            else
               tileset_quad_name = table.sample({
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty2,
               })
            end
         end

         local tile_id = entity_manager:new_entity_id()
         entity_manager:add_component(tile_id, create_component.position(level_name, point))
         entity_manager:add_component(tile_id, create_component.render(tileset_quad_name, 0))

         if tile_kind == tile_kinds.wall then
            entity_manager:add_component(tile_id, create_component.collision())
            entity_manager:add_component(tile_id, create_component.opaque())
         end
      end
   end
end
