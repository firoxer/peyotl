return function(tbl)
   assertx.is_table(tbl)

   local new_tbl = {}

   for _, value in ipairs(tbl) do
      new_tbl[value] = value
   end

   return new_tbl
end
