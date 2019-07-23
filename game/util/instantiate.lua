return function(prototype, object)
   setmetatable(object, { __index = prototype })

   object.bind = function(fn)
      return function(a, b, c, d, e, f)
         return object[fn](object, a, b, c, d, e, f)
      end
   end

   local caller_src = debug.getinfo(2, "S").short_src
   if caller_src ~= nil then
      local namespace, protoype_name = caller_src:match("game/([%l_/]-)([%l_]+)%.lua")
      object.type = (namespace .. string.camelcasify(protoype_name, true)):gsub("/", ".")
   end

   return object
end
