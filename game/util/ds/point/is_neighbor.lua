return function(a, b)
   assert(a.type == "ds.Point")
   assert(b.type == "ds.Point")

   local ax, ay = a.x, a.y
   local bx, by = b.x, b.y
   return (
      ax == bx - 1 and (ay == by - 1 or ay == by or ay == by + 1)
      or ax == bx and (ay == by - 1 or ay == by + 1)
      or ax == bx + 1 and (ay == by - 1 or ay == by or ay == by + 1)
   )
end
