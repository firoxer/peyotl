-- Using math.ceil ensures that the jaggedness matches with the map's edges
return function(algo_settings, level_width, level_height)
   assertx.is_table(algo_settings)
   assertx.is_number(level_width)
   assertx.is_number(level_height)

   local matrix = ds.Matrix()
   local random_offset = love.math.random(0, 1000)

   for y = 1, level_height do
      for x = 1, level_width do
         matrix:set(ds.Point.get(x, y), true)
      end
   end

   for y = 1, level_height do
      for x = 1, level_width do
         local modified_x =
            math.ceil(x / algo_settings.a_noise_jaggedness)
            * algo_settings.a_noise_jaggedness
            * algo_settings.a_noise_density
            + random_offset
         local modified_y =
            math.ceil(y / algo_settings.a_noise_jaggedness)
            * algo_settings.a_noise_jaggedness
            * algo_settings.a_noise_density
            + random_offset

         local noise = love.math.noise(modified_x, modified_y) -- Not affected by love.math.setRandomSeed

         if noise < algo_settings.a_noise_threshold then
            local point = ds.Point.get(x, y)
            if matrix:has(point) then
               matrix:set(point, false)
            end
         end
      end
   end

   for y = 1, level_height do
      for x = 1, level_width do
         local modified_x =
            math.ceil(x / algo_settings.b_noise_jaggedness)
            * algo_settings.b_noise_jaggedness
            * algo_settings.b_noise_density
            + random_offset
         local modified_y =
            math.ceil(y / algo_settings.b_noise_jaggedness)
            * algo_settings.b_noise_jaggedness
            * algo_settings.b_noise_density
            + random_offset

         local noise = love.math.noise(modified_x, modified_y) -- Not affected by love.math.setRandomSeed
         if noise > algo_settings.b_noise_threshold_low and noise < algo_settings.b_noise_threshold_high then
            local point = ds.Point.get(x, y)
            if matrix:has(point) then
               matrix:set(point, false)
            end
         end
      end
   end

   return matrix
end
