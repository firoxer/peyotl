return function(tbl, mapper)
   assertx.is_table(tbl)
   assertx.is_function(mapper)

   local new_tbl = {}
   for i, v in ipairs(tbl) do
      table.insert(new_tbl, mapper(i, v))
   end

   return new_tbl
end