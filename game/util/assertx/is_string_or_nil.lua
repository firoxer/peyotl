return function(x)
   if x ~= nil and type(x) ~= "string" then
      error("value should be string or nil, was " .. type(x), 2)
   end
end
