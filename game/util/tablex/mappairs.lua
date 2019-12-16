return function(tbl, mapper)
   assertx.is_table(tbl)
   assertx.is_function(mapper)

   for k, v in pairs(tbl) do
      tbl[k] = mapper(k, v)
   end

   return tbl
end
