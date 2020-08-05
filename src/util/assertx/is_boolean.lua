return function(x)
   if type(x) ~= "boolean" then
      error("value should be boolean, was " .. type(x), 2)
   end
end
