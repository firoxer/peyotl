return function(x)
   if x ~= true then
      error("value should be true, was " .. (x == false and "false" or type(x)), 2)
   end
end
