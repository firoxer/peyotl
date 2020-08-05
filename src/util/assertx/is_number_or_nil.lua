return function(x)
   if x ~= nil and type(x) ~= "number" then
      error("value should be number or nil, was " .. type(x), 2)
   end
end
