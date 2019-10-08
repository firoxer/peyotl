local get = require("game.util.ds.point.get")

return function(p, xd, yd)
   return get(p.x + xd, p.y + yd)
end
