return function(x)
   if type(x) ~= "function" then
      error("value should be function, was " .. type(x), 2)
   end
end
