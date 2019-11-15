local get = require("game.util.ds.point.get")

return function(p, xd, yd)
   assert(p.type == "ds.Point")
   assert(type(xd) == "number")
   assert(type(yd) == "number")

   return get(p.x + xd, p.y + yd)
end
