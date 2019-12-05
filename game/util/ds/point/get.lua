local points = {}

local metatable = {
   __tostring = function(p)
      return "{ x = " .. p.x .. ", y = " .. p.y .. " }"
   end
}
return function(x, y)
   assert(type(x) == "number")
   assert(type(y) == "number")

   if points[y] == nil then
      points[y] = {}
   end

   if points[y][x] == nil then
      local p = { x = x, y = y }

      setmetatable(p, metatable)

      p.type = "ds.Point" -- So that the code can assume this is a prototype

      points[y][x] = tablex.readonly(p)
   end

   return points[y][x]
end

