return function(tbl, mapper)
   assertx.is_table(tbl)
   assertx.is_function(mapper)

   local new_tbl = {}
   for k, v in pairs(tbl) do
      new_tbl[k] = mapper(k, v)
   end

   return new_tbl
end
