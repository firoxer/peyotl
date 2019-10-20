return function(tbl)
   assert(type(tbl) == "table")

   local cloned = {}

   for k, v in ipairs(tbl) do
      cloned[k] = v
   end

   for k, v in pairs(tbl) do
      cloned[k] = v
   end

   return cloned
end
