local get = require("src.util.ds.point.get")

return function(p, xd, yd)
   assertx.is_instance_of("ds.Point", p)
   assertx.is_number(xd)
   assertx.is_number(yd)

   return get(p.x + xd, p.y + yd)
end
