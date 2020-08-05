return function(tbl)
   assertx.is_table(tbl)

   local new_tbl = {}
   for k in pairs(tbl) do
      table.insert(new_tbl, k)
   end

   return new_tbl
end
