return function(prototype_name, x)
   if type(x) ~= "table" or x.type ~= prototype_name then
      error("value should be an instance of " .. prototype_name .. ", was " .. type(x), 2)
   end
end
