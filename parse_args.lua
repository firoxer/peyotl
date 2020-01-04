local config = require("config")
local devtools = require("devtools")

local Subject = require("game.event.subject")

local arg_reactions = {
   disable_vsync = function()
      config.rendering.enable_vsync = false
      log.debug("disabled vsync")
   end,

   god_mode = function()
      for _, level_config in pairs(config.levels) do
         level_config.player.initial_health = math.huge
      end
      log.debug("enabled god mode")
   end,

   log_events = function()
      Subject.enable_event_logging()
      log.debug("enabled event logging")
   end,

   profile = function()
      devtools.enable_profiling()
      log.debug("enabled profiling")
   end,

   report_memory_usage = function()
      devtools.enable_memory_usage_reports()
      log.debug("enabled memory usage reports")
   end,

   report_low_fps = function()
      devtools.enable_low_fps_reports()
      log.debug("enabled low FPS reports")
   end,

   retard_performance = function()
      devtools.enable_performance_retardation()
      log.debug("enabled performance retardation")
   end,
}
return function(raw_args)
   local args = {
      -- Defaults for development
      report_low_fps = true,
      retard_performance = true
   }

   for _, arg in ipairs(raw_args) do
      local key = arg:match("^%-%-([%w%-]+)=?")
      local value = arg:match("=(%w*)$")
      if not key then
         log.error("invalid argument: " .. arg)
         love.event.quit()
      end
      args[key:gsub("-", "_")] = value or true
   end

   if args.h or args.help then
      print([[usage: ./run [options]
    --log-events
    --production
    --profile
    --report-memory-usage
    --report-low-fps
    --retard-performance]])
      love.event.quit()
      return
   end

   if args.production then
      args.report_low_fps = nil
      args.retard_performance = nil
      args.production = nil
   end

   for key, value in pairs(args) do
      if not arg_reactions[key] then
         log.error("no reaction for CLI arg: " .. key)
      else
         arg_reactions[key](value)
      end
   end
end
