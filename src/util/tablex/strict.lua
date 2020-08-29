local metatable = {
   __index = function(_, key)
      error("trying to access table with nonpresent key: " .. key)
   end
}
local function strict(tbl)
   assertx.is_table(tbl)

   for _, value in pairs(tbl) do
      if type(value) == "table" then
         strict(value)
      end
   end

   return setmetatable(tbl, metatable)
end

return strict
