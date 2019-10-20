return function(tbl)
   assert(type(tbl) == "table")

   local size = #tbl
   local is_hash

   if #tbl == 0 then
      is_hash = true
      for _ in pairs(tbl) do
         size = size + 1
      end
   else
      is_hash = false
   end

   return is_hash, size
end
