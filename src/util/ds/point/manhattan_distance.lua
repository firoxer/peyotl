return function(a, b)
   assertx.is_instance_of("ds.Point", a)
   assertx.is_instance_of("ds.Point", b)

   return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end
