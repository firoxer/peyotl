return function(tbl)
   return setmetatable({}, {
      __index = tbl,

      __newindex = function(_, key)
         error("trying to set property of readonly table; key: " .. key)
      end
   })
end
