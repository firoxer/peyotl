local profiler = require("lib.profiler")

local profiling_on = false
local memory_usage_reporting_on = false
local low_fps_reporting_on = false
local performance_retardation_on = false

local function enable_profiling()
   profiling_on = true
   profiler.hookall("Lua")
   profiler.start()
end

local function enable_low_fps_reports()
   low_fps_reporting_on = true
end

local function enable_memory_usage_reports()
   memory_usage_reporting_on = true
end

local function enable_performance_retardation()
   performance_retardation_on = true
end

local frame = 0
local function _report_profiling()
   frame = frame + 1
   if frame % 100 == 0 then
      print(profiler.report("time", 20))
      profiler.reset()
   end
end

local prev_fps = 0
local function _report_low_fps()
   local fps = love.timer.getFPS()
   if fps < 60 and fps ~= prev_fps then
      log.debug("FPS under 60: " .. fps)
   end
   prev_fps = fps
end

local last_memory_usage = math.huge
local memory_usages = ds.CircularBuffer.new(60, { allow_overwrite = true })
local function _report_memory_usage()
   local memory_usage = collectgarbage("count")
   if memory_usage > last_memory_usage then
      memory_usages:write(memory_usage - last_memory_usage)
   end
   last_memory_usage = memory_usage

   local memory_usage_rate = 0
   for _, usage in memory_usages:ipairs() do
      memory_usage_rate = memory_usage_rate + usage
   end
   log.debug(string.format("mem rate: %.2f, total mem %5d", memory_usage_rate, memory_usage))
end

local time_to_sleep = 0.0148 -- Three fourths of a frame
local function _retard_performance()
   local t = love.timer.getTime()
   while love.timer.getTime() - t < time_to_sleep do
      -- Busy sleep
   end
end

local function tick()
   if profiling_on then
      _report_profiling()
   end

   if low_fps_reporting_on then
      _report_low_fps()
   end

   if memory_usage_reporting_on then
      _report_memory_usage()
   end

   if performance_retardation_on then
      _retard_performance()
   end
end

return {
   enable_profiling = enable_profiling,
   enable_low_fps_reports = enable_low_fps_reports,
   enable_memory_usage_reports = enable_memory_usage_reports,
   enable_performance_retardation = enable_performance_retardation,
   tick = tick
}
