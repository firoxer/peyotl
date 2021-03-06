local sqrt2 = math.sqrt(2)
local function calculate_distance(a, b) -- Optimized for only one step movements
   local diagonal_move = a.x ~= b.x and a.y ~= b.y
   return (diagonal_move and sqrt2 or 1)
end

local BreadthFirst = prototype(function(self, collision_matrix, max_distance)
   assertx.is_instance_of("ds.Matrix", collision_matrix)
   assertx.is_number_or_nil(max_distance)

   self._max_distance = max_distance or math.huge
   self._collision_matrix = collision_matrix
   self._parents = {}
   self._children = {}
   self._distances = {}
end)

function BreadthFirst:_recalculate_from(start_point)
   local max_distance = self._max_distance
   local parents = self._parents
   local children = self._children
   local distances = self._distances

   local open_queue = ds.Queue()
   open_queue:enqueue(start_point)

   -- No gotos in this while to buy performance with readability
   while not open_queue:is_empty() do
      local point = open_queue:dequeue()

      if distances[point] + 1 <= max_distance then
         for neighbor, collides in pairs(self._collision_matrix:get_immediate_neighbors(point)) do
            local actual_neighbor_distance = distances[point] + calculate_distance(point, neighbor)
            if distances[neighbor] == nil or actual_neighbor_distance < distances[neighbor] then
               distances[neighbor] = actual_neighbor_distance
               parents[neighbor] = point

               if not children[point] then
                  children[point] = {}
               end
               table.insert(children[point], neighbor)

               if not collides then
                  open_queue:enqueue(neighbor)
               end
            end
         end
      end
   end
end

function BreadthFirst:change_destination_to(origin_point)
   assertx.is_instance_of("ds.Point", origin_point)

   self._parents = {}
   self._children = {}
   self._distances = {}
   self._distances[origin_point] = 0

   self:_recalculate_from(origin_point)
end

function BreadthFirst:_reset_lineage(point)
   assertx.is_instance_of("ds.Point", point)

   self._parents[point] = nil
   self._distances[point] = nil

   if self._children[point] ~= nil then
      for _, child_point in ipairs(self._children[point]) do
         if self._distances[child_point] ~= nil then
            self:_reset_lineage(child_point)
         end
      end

      self._children[point] = nil
   end
end

function BreadthFirst:recalculate_at(point)
   assertx.is_instance_of("ds.Point", point)

   self:_reset_lineage(point)

   for neighbor, collides in pairs(self._collision_matrix:get_immediate_neighbors(point)) do
      -- This `not collides` prevents monsters from colliding into one another.
      -- I don't understand why and I think it would be better to move it to  `_recalculate_from`.
      if not collides and self._distances[neighbor] ~= nil then
         self:_recalculate_from(neighbor)
      end
   end
end

function BreadthFirst:find_next_step(point)
   assertx.is_instance_of("ds.Point", point)

   return self._parents[point]
end

return BreadthFirst
