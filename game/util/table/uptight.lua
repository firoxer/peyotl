local function uptight(tbl)
   for _, value in pairs(tbl) do
      if type(value) == "table" then
         uptight(value)
      end
   end

   return setmetatable(tbl, {
      __index = function(_, key)
         error("trying to access table with nonpresent key: " .. key)
      end
   })
end

return uptight
