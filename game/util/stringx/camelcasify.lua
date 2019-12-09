return function(str, pascal_case)
   assertx.is_string(str)
   assertx.is_boolean_or_nil(pascal_case)

   local camelcasified = {}
   for word in str:gmatch("([^_]+)_?") do
      table.insert(camelcasified, word:sub(1, 1):upper())
      table.insert(camelcasified, word:sub(2))
   end
   if #camelcasified >= 1 and not pascal_case then
      camelcasified[1] = camelcasified[1]:lower()
   end
   return table.concat(camelcasified)
end
