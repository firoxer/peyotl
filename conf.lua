function love.conf(t)
    -- For logging to work on Windows
   t.console = true

   -- Disabling things we don't need
   t.modules.data = false
   t.modules.joystick = false
   t.modules.physics = false
   t.modules.thread = false
   t.modules.touch = false
   t.modules.video = false
end
