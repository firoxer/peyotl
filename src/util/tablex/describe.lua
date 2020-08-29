return function(tbl)
   assertx.is_table(tbl)

   local size = #tbl

   if size == 0 then
      for _ in pairs(tbl) do
         size = size + 1
      end
      return "hash", size
   else
      return "array", size
   end
end
