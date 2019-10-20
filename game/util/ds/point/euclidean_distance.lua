return function(a, b)
   assert(type(a) == "number")
   assert(type(b) == "number")

   local xd = math.abs(a.x - b.x)
   local yd = math.abs(a.y - b.y)
   return math.sqrt(xd^2 + yd^2)
end
