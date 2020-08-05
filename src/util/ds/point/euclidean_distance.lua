return function(a, b)
   assertx.is_number(a)
   assertx.is_number(b)

   local xd = math.abs(a.x - b.x)
   local yd = math.abs(a.y - b.y)
   return math.sqrt(xd^2 + yd^2)
end
