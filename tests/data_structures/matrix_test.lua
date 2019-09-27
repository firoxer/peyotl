require("../../init")

local Point = require("../game/data_structures/point")
local Matrix = require("../game/data_structures/matrix")

do
   local tbl = {
      {"a", "b"},
      {"c", "d"},
   }

   local m = Matrix.new()
   m:set(Point.new(1, 1), "a")
   m:set(Point.new(2, 1), "b")
   m:set(Point.new(1, 2), "c")
   m:set(Point.new(2, 2), "d")

   for point, e in m:pairs() do
      assert(e == tbl[point.y][point.x])
   end
end
