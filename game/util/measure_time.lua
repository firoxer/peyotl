local start_time = nil

local function start()
   if start_time ~= nil then
      error("cannot start measuring time when a timer is already running")
   end

   start_time = love.timer.getTime()
end

local function stop()
   if start_time == nil then
      error("cannot stop measuring time when there is no timer running")
   end

   local measured_time = love.timer.getTime() - start_time
   start_time = nil
   return measured_time
end

local function stop_and_log(message)
   local measured_time = stop()
   log.debug(message .. " in " .. mathx.round(measured_time * 1000, 0.1) .. " ms")
end

local function inside(message, chunk)
   start()
   chunk()
   stop_and_log(message)
end

return {
   inside = inside,
   start = start,
   stop = stop,
   stop_and_log = stop_and_log,
}
