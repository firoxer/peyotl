local template = "%8s -- %s"
local template_with_data = "%8s -- %s -- %s"

local function log(level, message, data)
   if data ~= nil then
      print(template_with_data:format(level, message, tostring(data)))
   else
      print(template:format(level, message))
   end
end

return {
   debug = function(message, data)
      log("debug", message, data)
   end,

   info = function(message, data)
      log("info", message, data)
   end,
}
