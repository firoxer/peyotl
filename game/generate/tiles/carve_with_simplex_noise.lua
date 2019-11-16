-- Using math.ceil ensures that the jaggedness matches with the map's edges
return function(level_config)
   local algo = level_config.generation_algorithm_settings
   local matrix = ds.Matrix.new()
   local random_offset = love.math.random(0, 1000)

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         matrix:set(ds.Point.new(x, y), true)
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
               matrix:set(point, false)
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
               matrix:set(point, false)
            end
         end
      end
   end

   return matrix
end
