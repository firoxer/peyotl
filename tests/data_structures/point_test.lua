local Point = require("../game/data_structures/point")

do
   local p1 = Point.new(1, 1)
   local p2 = Point.new(1, 1)

   assert(p1 == p2)
end

do
   local p1 = Point.new(1, 1)
   local p2 = Point.new(1, 1)

   assert(p1.x == p2.x)
   assert(p1.y == p2.y)
end

do
   local p = Point.new(1, 1)

   local _, errx = pcall(function() p.x = 2 end)
   assert(errx ~= nil)

   local _, erry = pcall(function() p.x = 2 end)
   assert(erry ~= nil)
end
