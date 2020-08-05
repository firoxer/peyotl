local function prettyprint(tbl, max_level, indent)
   max_level = (max_level == nil) and math.huge or max_level
   indent = indent or 0

   if max_level == 0 then
      return
   end

   for k, v in pairs(tbl) do
      print(string.rep("    ", indent) .. "- " .. tostring(k) .. ": " .. tostring(v))

      if type(v) == "table" then
         prettyprint(v, max_level - 1, indent + 1)
      end
   end
end

return prettyprint
