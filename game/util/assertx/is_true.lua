return function(x)
   assert(x == true, "argument should be true, was " .. (x == false and "false" or type(x)))
end
