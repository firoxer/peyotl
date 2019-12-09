return function(x)
   assert(x == nil or type(x) == "function", "argument should be function or nil, was " .. type(x))
end
