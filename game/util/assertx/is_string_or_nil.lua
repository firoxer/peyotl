return function(x)
   assert(x == nil or type(x) == "string", "argument should be string or nil, was " .. type(x))
end
