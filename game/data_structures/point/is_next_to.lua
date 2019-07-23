return function(a, b)
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
