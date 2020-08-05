local points = {}

local metatable = {
   __tostring = function(p)
      return "{ x = " .. p.x .. ", y = " .. p.y .. " }"
   end
}
return function(x, y)
   assertx.is_number(x)
   assertx.is_number(y)

   if points[y] == nil then
      points[y] = {}
   end

   if points[y][x] == nil then
      local p = { x = x, y = y }

      setmetatable(p, metatable)

      -- So that the code can assume this is an object
      -- FIXME: This is fragile
      p.prototype = { name = "ds.Point" }

      points[y][x] = tablex.readonly(p)
   end

   return points[y][x]
end

