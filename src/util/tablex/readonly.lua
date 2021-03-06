return function(tbl)
   assertx.is_table(tbl)

   local mt = tablex.clone(getmetatable(tbl)) or {}

   mt.__index = tbl

   mt.__newindex = function(_, key)
      error("trying to set property of readonly table; key: " .. key)
   end

   return setmetatable({}, mt)
end
