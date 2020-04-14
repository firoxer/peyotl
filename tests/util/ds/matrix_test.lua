do
   local tbl = {
      {"a", "b"},
      {"c", "d"},
   }

   local m = ds.Matrix()
   m:set(ds.Point.get(1, 1), "a")
   m:set(ds.Point.get(2, 1), "b")
   m:set(ds.Point.get(1, 2), "c")
   m:set(ds.Point.get(2, 2), "d")

   for point, e in m:pairs() do
      assert(e == tbl[point.y][point.x])
   end
end
