local function log(level, message, data)
   assert(type(level) == "string")
   assert(type(message) == "string")

   if data == nil then
      print(string.format("%s: %s", level, message))
   else
      print(string.format("%s: %s -- %s", level, message, tostring(data)))
   end
end

return {
   debug = function(message, data)
      log("   [\27[37mdebug\27[0m]", message, data)
   end,

   info = function(message, data)
      log("    [\27[34minfo\27[0m]", message, data)
   end,

   warn = function(message, data)
      log("    [\27[33mwarn\27[0m]", message, data)
   end,

   error = function(message, data)
      log("   [\27[31merror\27[0m]", message, data)
   end,

   fatal = function(message, data)
      log("   [\27[37;1m\27[41;1mfatal\27[0m]", message, data)
   end,
}
