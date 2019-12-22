local bresenham_line = ds.Point.bresenham_line

local almost_sqrt2 = math.sqrt(2)
local function calculate_distance(a, b)
   local diagonal_move = a.x ~= b.x and a.y ~= b.y
   return (diagonal_move and almost_sqrt2 or 1)
end

local function breadth_first(lighting_settings, illuminabilities, camera_point)
   local max_distance = lighting_settings.lighting_range
   assertx.is_number(max_distance)

   local distances = ds.Matrix.new()
   local open_queue = ds.Queue.new()

   open_queue:enqueue(camera_point)
   distances:set(camera_point, 0)

   while not open_queue:is_empty() do
      local point = open_queue:dequeue()

      for neighbor_point, is_illuminable in pairs(illuminabilities:get_immediate_neighbors(point)) do
         local neighbor_distance = distances:get(point) + calculate_distance(point, neighbor_point)

         if neighbor_distance > max_distance then
            goto continue
         end

         local visible_from_camera =
            bresenham_line(camera_point, neighbor_point, tablex.bind(illuminabilities, "get"))
         if not visible_from_camera then
            goto continue
         end

         if distances:get(neighbor_point) ~= nil and neighbor_distance >= distances:get(neighbor_point) then
            goto continue
         end

         distances:set(neighbor_point, neighbor_distance)

         if is_illuminable then
            open_queue:enqueue(neighbor_point)
         end

         ::continue::
      end
   end

   return function(point)
      local distance = distances:get(point)

      if distance ~= nil then
         return 1
      end

      -- Edges of lighted areas
      for neighbor_point in pairs(illuminabilities:get_immediate_neighbors(point, true)) do
         if distances:has(neighbor_point) and illuminabilities:get(neighbor_point) == true then
            return 0.5
         end
      end

      return 0
   end
end

return function(settings, illuminabilities, camera_point)
   assertx.is_table(settings)
   assertx.is_instance_of("ds.Matrix", illuminabilities)
   assertx.is_instance_of("ds.Point", camera_point)

   if settings.algorithm == "full" then
      return function()
         return 1
      end
   elseif settings.algorithm == "fog_of_war" then
      return breadth_first(settings, illuminabilities, camera_point)
   else
      error("unknown lighting type: " .. settings.algorithm)
   end
end

