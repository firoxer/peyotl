do
   local tbl = {
      value = 1,
   }

   function tbl:increment_by(n)
      self.value = self.value + n
   end

   local bound_increment_by = tablex.bind(tbl, "increment_by")

   assert(tbl.value == 1)
   bound_increment_by(2)
   assert(tbl.value == 3)
end
