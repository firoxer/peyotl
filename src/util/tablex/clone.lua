return function(tbl)
   assertx.is_table(tbl)

   local cloned = {}

   for k, v in ipairs(tbl) do
      cloned[k] = v
   end

   for k, v in pairs(tbl) do
      cloned[k] = v
   end

   setmetatable(cloned, getmetatable(tbl))

   return cloned
end
