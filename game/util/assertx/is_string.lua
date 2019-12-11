return function(x)
   if type(x) ~= "string" then
      error("value should be string, was " .. type(x), 2)
   end
end
