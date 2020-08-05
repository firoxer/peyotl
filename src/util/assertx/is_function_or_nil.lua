return function(x)
   if x ~= nil and type(x) ~= "function" then
      error("value should be function or nil, was " .. type(x), 2)
   end
end
