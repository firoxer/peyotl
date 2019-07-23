local Point = require("game.data_structures.point")

local Matrix = {}

function Matrix:get(point)
   return self:_raw_get(point.x, point.y)
end

function Matrix:_raw_get(x, y)
   if self._contents[y] == nil then
      return nil
   end

   return self._contents[y][x]
end

function Matrix:set(point, elem)
   if self._contents[point.y] == nil then
      self._contents[point.y] = {}
   end

   self._contents[point.y][point.x] = elem

   self._nw_x = math.min(self._nw_x or math.huge, point.x)
   self._nw_y = math.min(self._nw_y or math.huge, point.y)
   self._se_x = math.max(self._se_x or -math.huge, point.x)
   self._se_y = math.max(self._se_y or -math.huge, point.y)
end

function Matrix:remove(point)
   if self:has(point) then
      self._contents[point.y][point.x] = nil
   end
end

function Matrix:has(point)
   return self._contents[point.y] ~= nil and self._contents[point.y][point.x] ~= nil
end

function Matrix:get_immediate_neighbors(point, von_neumann_only)
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

-- TODO: Optimize
function Matrix:ipairs()
   local function iter(tbl)
      for y, row in pairs(tbl) do
         for x, elem in pairs(row) do
            coroutine.yield(Point.new(x, y), elem)
         end
      end
   end

   return coroutine.wrap(function()
      iter(self._contents)
   end)
end

function Matrix:bounds()
   return
      Point.new(self._nw_x, self._nw_y),
      Point.new(self._se_x, self._se_y)
end

return {
   new = function()
      local instance = instantiate(Matrix, {
         _contents = {},
         _nw_x = nil,
         _nw_y = nil,
         _se_x = nil,
         _se_y = nil,
      })
      return instance
   end
}
