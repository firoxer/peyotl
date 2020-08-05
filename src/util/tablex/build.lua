return function(iter)
   assertx.is_function(iter)

   local tbl = {}
   for x in iter do
      table.insert(tbl, x)
   end
   return tbl
end
