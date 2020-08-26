local TIME_TO_SLEEP = 0.0148 -- Three fourths of a frame

return function()
   local t = love.timer.getTime()
   while love.timer.getTime() - t < TIME_TO_SLEEP do
      -- Busy sleep
   end
end