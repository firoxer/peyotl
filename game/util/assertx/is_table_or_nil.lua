return function(x)
   assert(x == nil or type(x) == "table", "argument should be table or nil, was " .. type(x))
end

