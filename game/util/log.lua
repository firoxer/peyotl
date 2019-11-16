local level_headers = love.system.getOS() == "Linux"
   and {
      debug =
         "   [\27[37mdebug\27[0m]",
      info =
         "    [\27[34minfo\27[0m]",
      warn =
         "    [\27[33mwarn\27[0m]",
      error =
         "   [\27[31merror\27[0m]",
      fatal =
         "   [\27[37;1m\27[41;1mfatal\27[0m]",
   }
   or {
      debug =
         "   [debug]",
      info =
         "    [info]",
      warn =
         "    [warn]",
      error =
         "   [error]",
      fatal =
         "   [fatal]",
   }

return table.mappairs(level_headers, function(_, header)
   return function(message, data)
      assert(type(message) == "string")

      if data == nil then
         print(string.format("%s: %s", header, message))
      else
         print(string.format("%s: %s -- %s", header, message, tostring(data)))
      end
   end
end)