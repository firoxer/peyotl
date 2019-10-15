local metatable = {
   __index = function(_, key)
      error("trying to access table with nonpresent key: " .. key)
   end
}
local function uptight(tbl)
   for _, value in pairs(tbl) do
      if type(value) == "table" then
         uptight(value)
      end
   end

   return setmetatable(tbl, metatable)
end

return uptight
