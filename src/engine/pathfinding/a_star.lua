local create_node = function(point)
   local node
   node = {
      x = point.x,
      y = point.y,

      opened = false,
      closed = false,
      parent = nil,
      cost = nil,

      reset = function()
         node.opened = false
         node.closed = false
         node.parent = nil
         node.cost = nil
      end
   }

   return node
end

local function backtrace(node) -- TODO: Return a linked list?
   local path = {}
   table.insert(path, node)

   local current_node = node

   while current_node.parent ~= nil do
      current_node = current_node.parent
      table.insert(path, current_node)
   end

   tablex.reverse(path)

   return path
end

local Pathfinder = prototype(function(self, is_walkable_at, nw_bound, se_bound, options)
   assertx.is_function(is_walkable_at)
   assertx.is_number(nw_bound.x)
   assertx.is_number(nw_bound.y)
   assertx.is_number(se_bound.x)
   assertx.is_number(se_bound.y)
   assertx.is_table_or_nil(options)

   self._is_walkable_at = is_walkable_at
   self._nw_bound = nw_bound
   self._se_bound = se_bound

   self._prefer_orthogonal = options and options.prefer_orthogonal or false

   self._node_matrix = ds.Matrix()

   return self
end)

function Pathfinder:reset()
   local nw_bound_x, nw_bound_y = self._nw_bound.x, self._nw_bound.y
   local se_bound_x, se_bound_y = self._se_bound.x, self._se_bound.y
   local is_walkable_at = self._is_walkable_at
   local node_matrix = self._node_matrix

   for y = nw_bound_y, se_bound_y do
      for x = nw_bound_x, se_bound_x do
         local point = ds.Point.get(x, y)
         if is_walkable_at(point) then
            if not node_matrix:has(point) then
               node_matrix:set(point, create_node(point))
            else
               node_matrix:get(point):reset()
            end
         else
            node_matrix:set(point, nil)
         end
      end
   end
end

local sqrt2 = math.sqrt(2)
function Pathfinder:find_path(a, b)
   self:reset()

   -- The origin node is always there because otherwise monsters would think
   -- they can't leave their own tile
   local origin_node = create_node(a)
   local destination_node = self._node_matrix:get(b)

   if destination_node == nil then
      return nil
   end

   origin_node.opened = true
   origin_node.cost = 0

   local open_queue = ds.PriorityQueue()
   open_queue:enqueue(origin_node, 0)

   while not open_queue:is_empty() do
      local node = open_queue:dequeue()
      node.closed = true

      if ds.Point.overlaps(node, destination_node) then
         return backtrace(node)
      end

      local neighbors = self._node_matrix:get_immediate_neighbors(node, self._prefer_orthogonal)
      for _, neighbor in pairs(neighbors) do
         if neighbor.closed then
            goto continue
         end

         -- To penalize diagonal movement
         local diagonal_move = node.x ~= neighbor.x and node.y ~= neighbor.y
         local new_cost = node.cost + (diagonal_move and sqrt2 or 1)

         if neighbor.opened and new_cost >= neighbor.cost then
            goto continue
         end

         neighbor.opened = true
         neighbor.cost = new_cost
         neighbor.parent = node

         local distance = ds.Point.chebyshev_distance(neighbor, b)
         local priority = neighbor.cost + distance
         open_queue:enqueue(neighbor, priority)

         ::continue::
      end
   end

   return nil
end

return Pathfinder
