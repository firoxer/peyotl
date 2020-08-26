local ArgParser = prototype(function(self, reactions)
   self._reactions = reactions or {}
end)

function ArgParser:trigger_reaction(name, ...)
   local reaction = self._reactions[name]

   if not reaction then
      self:_print_help()
      error("unknown argument: " .. name)
   end

   reaction(...)
end

function ArgParser:_print_help()
   print("usage ./run [options]") -- FIXME: This is not always "./run"

   for key in pairs(self._reactions) do
      print("    " .. key)
   end
end

function ArgParser:parse(args)
   for _, arg in ipairs(args) do
      local name = arg:match("^(%-%-[%w%-]+)=?")
      local value = arg:match("=(%w*)$")

      if not name then
         log.error("invalid argument: " .. arg)
         love.event.quit()
      end

      if name == "-h" or name == "--help" then
         self._print_help()
         love.event.quit()
      end

      self:trigger_reaction(name, value)
   end
end

return ArgParser