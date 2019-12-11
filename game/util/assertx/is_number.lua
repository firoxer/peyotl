return function(x)
   if type(x) ~= "number" then
      error("value should be number, was " .. type(x), 2)
   end
end
