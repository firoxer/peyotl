return function(tbl)
   assertx.is_table(tbl)

   local table_type, table_size = tablex.describe(tbl)

   if table_size == 0 then
      error("trying to get sample from empty table")
   end

   local rand_index = math.ceil(love.math.random() * table_size)

   if table_type == "hash" then
      local key = nil

      for _ = 1, rand_index do
         key = next(tbl, key)
      end

      return tbl[key]
   else
      return tbl[rand_index]
   end
end
