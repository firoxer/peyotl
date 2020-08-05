return function(x)
   if x ~= nil and type(x) ~= "boolean" then
      error("value should be boolean or nil, was " .. type(x), 2)
   end
end
