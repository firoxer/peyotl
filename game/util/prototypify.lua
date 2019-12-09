return function(prototype)
   assertx.is_table(prototype)

   local metatable = { __index = prototype }

   local object_type = nil
   local caller_src = debug.getinfo(2, "S").short_src
   if caller_src ~= nil then
      local namespace, prototype_name = caller_src:match("game/([%l_/]-)([%l_]+)%.lua")
      object_type = (namespace .. stringx.camelcasify(prototype_name, true)):gsub("/", ".")
   end

   return function(object)
      setmetatable(object, metatable)

      object.bind = function(fn)
         return function(a, b, c, d, e, f)
            return object[fn](object, a, b, c, d, e, f)
         end
      end

      object.type = object_type

      return object
   end
end
