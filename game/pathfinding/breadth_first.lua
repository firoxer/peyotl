local sqrt2 = math.sqrt(2)
local function calculate_distance(a, b)
   local diagonal_move = a.x ~= b.x and a.y ~= b.y
   return (diagonal_move and sqrt2 or 1)
end

local BreadthFirst = {}

function BreadthFirst:update_origin(origin_point)
   self._parents = {}
   self._distances = {}
   self._distances[origin_point] = 0

   self:_traverse_from(origin_point)
end

function BreadthFirst:_traverse_from(origin_point)
   local max_distance = self._max_distance
   local parents = self._parents
   local distances = self._distances

   local open_queue = ds.Queue.new()
   open_queue:enqueue(origin_point)

   while not open_queue:is_empty() do
      local point = open_queue:dequeue()

      local neighbor_distance = distances[point] + 1
      if neighbor_distance > max_distance then
         goto continue
      end

      for neighbor_point, collides in pairs(self._collision_matrix:get_immediate_neighbors(point)) do
         if distances[neighbor_point] == nil or neighbor_distance < distances[neighbor_point] then
            distances[neighbor_point] = distances[point] + calculate_distance(point, neighbor_point)
            parents[neighbor_point] = point

            if not collides then
               open_queue:enqueue(neighbor_point)
            end
         end
      end

      ::continue::
   end

   self._parents = parents
   self._distances = distances
end

function BreadthFirst:update_point(point)
   local lowest_neighbor_distance = math.huge
   local lowest_neighbor_point = nil
   for neighbor_point in pairs(self._collision_matrix:get_immediate_neighbors(point)) do
      local neighbor_distance = self._distances[neighbor_point]
      if neighbor_distance ~= nil and neighbor_distance < lowest_neighbor_distance then
         lowest_neighbor_distance = neighbor_distance
         lowest_neighbor_point = neighbor_point
      end
   end

   if lowest_neighbor_point ~= nil and self._collision_matrix:get(point) == false then
      self._distances[point] = lowest_neighbor_distance + calculate_distance(point, lowest_neighbor_point)
   else
      self:_reset_lineage(point)
   end

   self:_traverse_from(point)
end

function BreadthFirst:_reset_lineage(point)
   for child_point, parent in pairs(self._parents) do
      if point == parent then
         self._parents[child_point] = nil
         self:_reset_lineage(child_point)
      end
   end
end

function BreadthFirst:find_next_step(point)
   return self._parents[point]
end

return {
   new = function(collision_matrix, level, max_distance)
      local instance = instantiate(BreadthFirst, {
         level = level,

         _max_distance = max_distance,
         _collision_matrix = collision_matrix,
         _parents = {},
         _distances = {},
      })
      return instance
   end
}