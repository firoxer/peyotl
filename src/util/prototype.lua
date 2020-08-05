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

return function(parent_prototype, initialize)
   if type(parent_prototype) == "function" then
      -- No parent was provided, just the initialize function
      initialize = parent_prototype
      parent_prototype = nil
   end

   local prototype = { prototype = parent_prototype }

   assign_name(prototype)

   initialize = initialize or function()
      -- No-op, just to make it certain that `initialize` is always callable
   end

   prototype.initialize = function(...)
      if parent_prototype then
         parent_prototype.initialize(...)
      end

      initialize(...)
   end

   setmetatable(prototype, {
      __call = function(_, ...)
         local instance = { prototype = prototype }
         setmetatable(instance, { __index = prototype })

         instance.initialize(instance, ...)

         return instance
      end,

      __index = parent_prototype
   })

   return prototype
end
