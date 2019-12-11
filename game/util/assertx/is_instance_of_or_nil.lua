return function(prototype_name, x)
   if x ~= nil and x.type ~= prototype_name then
      error("value should be an instance of " .. prototype_name .. " or nil, was " .. type(x), 2)
   end
end
