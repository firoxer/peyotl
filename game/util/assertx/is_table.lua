return function(x)
   if type(x) ~= "table" then
      error("value should be table, was " .. type(x), 2)
   end
end

