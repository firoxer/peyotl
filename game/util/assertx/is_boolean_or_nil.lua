return function(x)
   assert(x == nil or type(x) == "boolean", "argument should be boolean or nil, was " .. type(x))
end
