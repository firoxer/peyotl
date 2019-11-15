return function(a, b)
   assert(type(a) == "table")
   assert(type(b) == "table")

   local new = {}

   for _, elem in ipairs(a) do
      table.insert(new, elem)
   end

   for _, elem in ipairs(b) do
      table.insert(new, elem)
   end

   return new
end
