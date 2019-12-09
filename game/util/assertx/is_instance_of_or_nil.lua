return function(prototype_name, x)
   assert(
      x == nil or x.type == prototype_name,
      "argument should be an instance of " .. prototype_name .. " or nil, was " .. type(x)
   )
end
