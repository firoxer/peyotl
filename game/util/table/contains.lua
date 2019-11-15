return function(tbl, value)
   assert(type(tbl) == "table")

   for _, elem in pairs(tbl) do
      if elem == value then
         return true
      end
   end

   return false
end
