local get = require("game.data_structures.point.get")

return function(p, xd, yd)
   return get(p.x + xd, p.y + yd)
end
