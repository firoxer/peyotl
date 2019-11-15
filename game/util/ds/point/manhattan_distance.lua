return function(a, b)
   assert(a.type == "ds.Point")
   assert(b.type == "ds.Point")

   return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end
