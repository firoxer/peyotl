--- Assign a name to the prototype for type checks
local function assign_name(prototype)
   if prototype.name ~= nil then
      return
   end

   local caller_src = debug.getinfo(3, "S").source

   if caller_src == nil then
      prototype.name = "unknown"
      return
   end

   local parts = tablex.build(caller_src:gmatch("([%l_]+)"))

   -- Sanity checks
   assertx.is_true(parts[1] == "src")
   table.remove(parts, 1)
   assertx.is_true(parts[#parts] == "lua")
   table.remove(parts, #parts)

   if parts[1] == "util" and parts[2] == "ds" then
      -- Data structures' (ds) names are too noisy with the `util` part in them
      table.remove(parts, 1)
   end

   local prototype_name = table.remove(parts, #parts)
   local namespace = table.concat(parts, ".")

   prototype.name = (namespace .. "." .. stringx.camelcasify(prototype_name, true)):gsub("/", ".")
end

return function(prototype, parent_prototype)
   assertx.is_table(prototype)

   assign_name(prototype)

   prototype.prototype = parent_prototype

   setmetatable(prototype, {
      __call = function(_, ...)
         local object = { prototype = prototype }
         setmetatable(object, { __index = prototype })

         if parent_prototype ~= nil then
            parent_prototype.initialize(object, ...)
         end

         prototype.initialize(object, ...)

         return object
      end,

      __index = parent_prototype
   })

   return prototype
end
