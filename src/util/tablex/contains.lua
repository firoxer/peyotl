return function(tbl, value)
   assertx.is_table(tbl)

   for _, elem in pairs(tbl) do
      if elem == value then
         return true
      end
   end

   return false
end
