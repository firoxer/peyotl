local FastMatrix = {}

function FastMatrix:get(point)
   return self:_raw_get(point.x, point.y)
end

function FastMatrix:_raw_get(x, y)
   return self._contents[(y - 1) * self._height + x]
end

function FastMatrix:set(point, elem)
   self._contents[(point.y - 1) * self._height + point.x] = elem
end

function FastMatrix:has(point)
   local x, y = point.x, point.y
   return
      x >= 1
      and x <= self._width
      and y >= 1
      and y <= self._height
      and self:get(x, y)
end

function FastMatrix:ipairs()
   return ipairs(self._contents)
end

function FastMatrix:get_immediate_neighbors(point)
   local x, y = point.x, point.y

   local neighbors = {}

   local n = self:_raw_get(x, y - 1)
   if n then
      table.insert(neighbors, n)
   end

   local e = self:_raw_get(x + 1, y)
   if e then
      table.insert(neighbors, e)
   end

   local s = self:_raw_get(x, y + 1)
   if s then
      table.insert(neighbors, s)
   end

   local w = self:_raw_get(x - 1, y)
   if w then
      table.insert(neighbors, w)
   end

   local nw = self:_raw_get(x - 1, y - 1)
   if nw then
      table.insert(neighbors, nw)
   end

   local ne = self:_raw_get(x + 1, y - 1)
   if ne then
      table.insert(neighbors, ne)
   end

   local se = self:_raw_get(x + 1, y + 1)
   if se then
      table.insert(neighbors, se)
   end

   local sw = self:_raw_get(x - 1, y + 1)
   if sw then
      table.insert(neighbors, sw)
   end

   return neighbors
end

return {
   new = function(width, height)
      assert(type(width) == "number")
      assert(type(height) == "number")

      local contents = {}
      for i = 1, width * height do
         contents[i] = false
      end

      local instance = instantiate(FastMatrix, {
         _width = width,
         _height = height,
         _contents = contents,
      })
      return instance
   end
}
