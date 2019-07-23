local points = {}

return function(x, y)
   if points[y] == nil then
      points[y] = {}
   end

   if points[y][x] == nil then
      local p = { x = x, y = y }
      p.type = "data_structures.Point" -- So that the code can assume this is a prototype
      points[y][x] = table.readonly(p)
   end

   return points[y][x]
end

