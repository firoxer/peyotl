return function(a, b)
   assertx.is_instance_of("ds.Point", a)
   assertx.is_instance_of("ds.Point", b)

   local ax, ay = a.x, a.y
   local bx, by = b.x, b.y

   return
      ax == bx and ay == by - 1
      or ax == bx + 1 and ay == by - 1
      or ax == bx + 1 and ay == by
      or ax == bx + 1 and ay == by + 1
      or ax == bx and ay == by + 1
      or ax == bx - 1 and ay == by + 1
      or ax == bx - 1 and ay == by
      or ax == bx - 1 and ay == by - 1
end
