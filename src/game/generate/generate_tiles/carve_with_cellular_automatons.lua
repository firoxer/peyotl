return function(algo_settings, width, height)
   assertx.is_table(algo_settings)
   assertx.is_number(width)
   assertx.is_number(height)

   local matrix = ds.Matrix()

   for y = 1, height do
      for x = 1, width do
         if love.math.random() < algo_settings.initial_wall_chance then
            matrix:set(ds.Point.get(x, y), true)
         else
            matrix:set(ds.Point.get(x, y), false)
         end
      end
   end

   for _ = 1, algo_settings.iterations do
      local updates = {}

      for y = 1, height do
         for x = 1, width do
            local point = ds.Point.get(x, y)
            local is_wall = matrix:get(point)

            local neighbors = matrix:get_immediate_neighbors(point)

            local alive_neighbors_n = 8
            for _, neighbor_is_wall in pairs(neighbors) do
               if not neighbor_is_wall then
                  alive_neighbors_n = alive_neighbors_n - 1
               end
            end

            if is_wall then
               if alive_neighbors_n < algo_settings.survival_threshold then
                  table.insert(updates, function()
                     matrix:set(point, false)
                  end)
               end
            else
               if alive_neighbors_n >= algo_settings.birth_threshold then
                  table.insert(updates, function()
                     matrix:set(point, true)
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
