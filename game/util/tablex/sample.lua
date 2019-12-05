return function(tbl)
   assert(type(tbl) == "table")

   local is_hash_table, table_size = tablex.describe(tbl)

   if table_size == 0 then
      error("trying to get sample from empty table")
   end

   local rand_index = math.ceil(love.math.random() * table_size)

   if is_hash_table then
      local i = 0
      for _, elem in pairs(tbl) do
         i = i + 1
         if i == rand_index then
            return elem
         end
      end
   else
      return tbl[rand_index]
   end
end
