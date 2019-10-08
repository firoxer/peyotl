local get = require("game.util.ds.point.get")

--- Bresenham line algorithm
-- From https://stackoverflow.com/questions/4672279/bresenham-algorithm-in-javascript
--
-- Calls the callback for every position, carries on if the callback returns true
return function(a, b, callback)
   local ax, ay = a.x, a.y
   local bx, by = b.x, b.y

   local dx = math.abs(bx - ax)
   local dy = math.abs(by - ay)
   local sx = (ax < bx) and 1 or -1
   local sy = (ay < by) and 1 or -1
   local err = dx - dy

   local x = ax
   local y = ay

   while true do
      if x == bx and y == by then
         return true
      end

      if not callback(get(x, y)) then
         return false
      end

      local e2 = err * 2

      if e2 > -dy then
         err = err - dy
         x = x + sx
      end

      if e2 < dx then
         err = err + dx
         y = y + sy
      end
   end
end

