return function(a, b)
   local new = {}

   for _, elem in ipairs(a) do
      table.insert(new, elem)
   end

   for _, elem in ipairs(b) do
      table.insert(new, elem)
   end

   return new
end
