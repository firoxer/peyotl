return function(x)
   if x ~= nil and type(x) ~= "table" then
      error("value should be table or nil, was " .. type(x), 2)
   end
end

