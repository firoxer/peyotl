local MemoryUsageReporter = prototype(function(self)
   self.last_usage = math.huge
   self.usages = ds.CircularBuffer(10, { allow_overwrite = true })
end)

local REPORT_STRING = "avg mem rate: %6.2fkb/frame; total mem: %5dkb"

function MemoryUsageReporter:tick()
   local current_usage = collectgarbage("count")
   if current_usage > self.last_usage then
      self.usages:write(current_usage - self.last_usage)
   end
   self.last_usage = current_usage

   local usage_rate = 0
   local usage_n = 0
   for _, usage in self.usages:ipairs() do
      usage_rate = usage_rate + usage
      usage_n = usage_n + 1
   end

   if usage_n == 0 then
      return
   end

   usage_rate = usage_rate / usage_n

   log.debug(string.format(REPORT_STRING, usage_rate, current_usage))
end

return MemoryUsageReporter