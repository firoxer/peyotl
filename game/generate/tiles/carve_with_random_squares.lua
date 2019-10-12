local tile_kinds = require("game.generate.tiles.kinds")

return function(level_config)
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
