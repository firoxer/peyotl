return function(tbl)
   assert(type(tbl) == "table")

   local mt = table.clone(getmetatable(tbl)) or {}

   mt.__index = tbl

   mt.__newindex = function(_, key)
      error("trying to set property of readonly table; key: " .. key)
   end

   return setmetatable({}, mt)
end
