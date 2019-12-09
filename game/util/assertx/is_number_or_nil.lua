return function(x)
   assert(x == nil or type(x) == "number", "argument should be number or nil, was " .. type(x))
end
