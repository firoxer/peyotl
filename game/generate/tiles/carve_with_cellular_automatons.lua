local tile_kinds = require("game.generate.tiles.kinds")

return function(level_config)
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
