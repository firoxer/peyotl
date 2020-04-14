return function(prototype_name, x)
   return x == nil or assertx.is_instance_of(prototype_name, x)
end
