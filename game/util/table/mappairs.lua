return function(tbl, map)
   for k, v in pairs(tbl) do
      tbl[k] = map(k, v)
   end

   return tbl
end
