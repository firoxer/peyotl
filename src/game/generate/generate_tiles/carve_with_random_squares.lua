return function(algo_settings, width, height)
   assertx.is_table(algo_settings)
   assertx.is_number(width)
   assertx.is_number(height)

   local matrix = ds.Matrix()

   local calculate_free_area = function()
      local wall_n = 0
      local empty_n = 0

      for _, is_wall in matrix:pairs() do
         if is_wall then
            wall_n = wall_n + 1
         else
            empty_n = empty_n + 1
         end
      end

      if wall_n == 0 and empty_n == 0 then
         error("matrix is empty")
      end

      return wall_n / (wall_n + empty_n)
   end

   for y = 1, height do
      for x = 1, width do
         matrix:set(ds.Point.get(x, y), false)
      end
   end

   while calculate_free_area() < algo_settings.minimum_wall_density do
      local random_nw_x = love.math.random(width)
      local random_nw_y = love.math.random(height)
      local square_size = love.math.random(algo_settings.square_size_min, algo_settings.square_size_max)
      local random_se_x = math.min(width, random_nw_x + square_size)
      local random_se_y = math.min(height, random_nw_y + square_size)

      for y = random_nw_y, random_se_y do
         for x = random_nw_x, random_se_x do
            matrix:set(ds.Point.get(x, y), true)
         end
      end
   end

   return matrix
end
