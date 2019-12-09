return function(prototype_name, x)
   assert(
      x.type == prototype_name,
      "argument should be an instance of " .. prototype_name .. ", was " .. type(x)
   )
end
