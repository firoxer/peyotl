return function(a, b)
   assert(a.type == "ds.Point")
   assert(b.type == "ds.Point")

   return a.x == b.x and a.y == b.y
end
