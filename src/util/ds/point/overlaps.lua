return function(a, b)
   assertx.is_instance_of("ds.Point", a)
   assertx.is_instance_of("ds.Point", b)

   return a.x == b.x and a.y == b.y
end
