-- This file is required before ds is defined so we have to require Point manually
local Point = require("game.util.ds.point")

local yield = coroutine.yield

local Matrix = {}

function Matrix:get(point)
   assert(point.type == "ds.Point")

   return self:_raw_get(point.x, point.y)
end

function Matrix:_raw_get(x, y)
   assert(type(x) == "number")
   assert(type(y) == "number")

   if self._contents[y] == nil then
      return nil
   end

   return self._contents[y][x]
end

function Matrix:set(point, elem)
   assert(point.type == "ds.Point")

   if self._contents[point.y] == nil then
      self._contents[point.y] = {}
   end

   self._contents[point.y][point.x] = elem

   self._bounds_up_to_date = false
end

function Matrix:remove(point)
   assert(point.type == "ds.Point")

   if self:has(point) then
      self._contents[point.y][point.x] = nil
   end

   self._bounds_up_to_date = false
end

function Matrix:has(point)
   assert(point.type == "ds.Point")

   return self._contents[point.y] ~= nil and self._contents[point.y][point.x] ~= nil
end

function Matrix:get_immediate_neighbors(point, von_neumann_only)
   assert(point.type == "ds.Point")
   assert(von_neumann_only == nil or type(von_neumann_only) == "boolean")

   local x, y = point.x, point.y

   local neighbors = {}

   local n = self:_raw_get(x, y - 1)
   if n ~= nil then
      neighbors[Point.new(x, y - 1)] = n
   end

   local e = self:_raw_get(x + 1, y)
   if e ~= nil then
      neighbors[Point.new(x + 1, y)] = e
   end

   local s = self:_raw_get(x, y + 1)
   if s ~= nil then
      neighbors[Point.new(x, y + 1)] = s
   end

   local w = self:_raw_get(x - 1, y)
   if w ~= nil then
      neighbors[Point.new(x - 1, y)] = w
   end

   if von_neumann_only then
      return neighbors
   end

   local nw = self:_raw_get(x - 1, y - 1)
   if nw ~= nil then
      neighbors[Point.new(x - 1, y - 1)] = nw
   end

   local ne = self:_raw_get(x + 1, y - 1)
   if ne ~= nil then
      neighbors[Point.new(x + 1, y - 1)] = ne
   end

   local se = self:_raw_get(x + 1, y + 1)
   if se ~= nil then
      neighbors[Point.new(x + 1, y + 1)] = se
   end

   local sw = self:_raw_get(x - 1, y + 1)
   if sw ~= nil then
      neighbors[Point.new(x - 1, y + 1)] = sw
   end

   return neighbors
end

function Matrix:get_neighbors(point, range)
   assert(point.type == "ds.Point")
   assert(type(range) == "number")

   local neighbors = {}

   for offset_y = -range, range do
      for offset_x = -range, range do
         if offset_x ~= 0 or offset_y ~= 0 then
            table.insert(neighbors, self:_raw_get(point.x + offset_x, point.y + offset_y))
         end
      end
   end

   return neighbors
end

function Matrix:pairs()
   local function iter(tbl)
      for y, row in pairs(tbl) do
         for x, elem in pairs(row) do
            yield(Point.new(x, y), elem)
         end
      end
   end

   return coroutine.wrap(function()
      iter(self._contents)
   end)
end

-- TODO: Check if this can be optimized
function Matrix:submatrix_pairs(nw_x, nw_y, se_x, se_y)
   assert(type(nw_x) == "number")
   assert(type(nw_y) == "number")
   assert(type(se_x) == "number")
   assert(type(se_y) == "number")

   local function iter(tbl)
      for y, row in pairs(tbl) do
         if y >= nw_y and y <= se_y then
            for x, elem in pairs(row) do
               if x >= nw_x and x <= se_x then
                  yield(Point.new(x, y), elem)
               end
            end
         end
      end
   end

   return coroutine.wrap(function()
      iter(self._contents)
   end)
end

function Matrix:bounds()
   if not self._bounds_up_to_date then
      local nw_x = math.huge
      local nw_y = math.huge
      local se_x = math.huge
      local se_y = math.huge
      for point in self:pairs() do
         nw_x = math.min(nw_x, point.x)
         nw_y = math.min(nw_y, point.y)
         se_x = math.max(se_x, point.x)
         se_y = math.max(se_y, point.y)
      end
      self._nw_bound = Point.new(nw_x, nw_y)
      self._se_bound = Point.new(se_x, se_y)

      self._bounds_up_to_date = true
   end

   return self._nw_bound, self._se_bound
end

local create_object = prototypify(Matrix)
return {
   new = function()
      return create_object({
         _contents = {},
         _bounds_up_to_date = true,
         _nw_bound = nil,
         _se_bound = nil,
      })
   end
}
