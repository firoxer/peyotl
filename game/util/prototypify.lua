return function(prototype)
   assertx.is_table(prototype)

   local metatable = { __index = prototype }

   local object_type = nil
   local caller_src = debug.getinfo(2, "S").source
   if caller_src ~= nil then
      local parts = tablex.build(caller_src:gmatch("([%l_]+)"))

      -- Sanity checks
      assertx.is_true(parts[1] == "game")
      table.remove(parts, 1)
      assertx.is_true(parts[#parts] == "lua") -- Sanity check
      table.remove(parts, #parts)

      if parts[1] == "util" and parts[2] == "ds" then
         -- Data structures' (ds) names are too noisy with the `util` part in them
         table.remove(parts, 1)
      end

      local prototype_name = table.remove(parts, #parts)
      local namespace = table.concat(parts, ".")

      object_type = (namespace .. "." .. stringx.camelcasify(prototype_name, true)):gsub("/", ".")
   end

   return function(object)
      setmetatable(object, metatable)
      object.type = object_type
      return object
   end
end
