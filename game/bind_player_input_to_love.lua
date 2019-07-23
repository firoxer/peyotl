local events = require("game.event.events")
local subjects = require("game.event.subjects")

return function(player_input_config)
   local short_tick = player_input_config.keyboard_short_tick_s
   local long_tick = player_input_config.keyboard_long_tick_s
   local key_tick_intervals = table.uptight({
      escape = long_tick,
      q = long_tick,

      p = long_tick,
      space = long_tick,
      c = long_tick,

      w = short_tick,
      a = short_tick,
      s = short_tick,
      d = short_tick,
   })

   local pressed_keys = {}

   love.keypressed = function(key)
      pressed_keys[key] = key_tick_intervals[key]

      -- Synchronize keys for diagonal movement
      if (key == "a" or key == "d") and pressed_keys.w ~= nil then
         pressed_keys.w = key_tick_intervals[key]
      elseif (key == "w" or key == "s") and pressed_keys.d ~= nil then
         pressed_keys.d = key_tick_intervals[key]
      elseif (key == "a" or key == "d") and pressed_keys.s ~= nil then
         pressed_keys.s = key_tick_intervals[key]
      elseif (key == "w" or key == "s") and pressed_keys.a ~= nil then
         pressed_keys.a = key_tick_intervals[key]
      end
   end

   love.keyreleased = function(key)
      pressed_keys[key] = nil
   end

   return function(dt)
      local activated_keys

      for key in pairs(pressed_keys) do
         pressed_keys[key] = pressed_keys[key] + dt

         if pressed_keys[key] >= key_tick_intervals[key] then
            if not activated_keys then
               activated_keys = {}
            end

            activated_keys[key] = true

            pressed_keys[key] = pressed_keys[key] - key_tick_intervals[key]
         end
      end

      if not activated_keys then
         return
      end

      if activated_keys.w then
         if activated_keys.a then
            subjects.player_input:notify(events.move_nw)
         elseif activated_keys.d then
            subjects.player_input:notify(events.move_ne)
         else
            subjects.player_input:notify(events.move_n)
         end
      elseif activated_keys.s then
         if activated_keys.a then
            subjects.player_input:notify(events.move_sw)
         elseif activated_keys.d then
            subjects.player_input:notify(events.move_se)
         else
            subjects.player_input:notify(events.move_s)
         end
      elseif activated_keys.a then
         subjects.player_input:notify(events.move_w)
      elseif activated_keys.d then
         subjects.player_input:notify(events.move_e)
      end

      if activated_keys.c then
         subjects.player_input:notify(events.warp)
      end

      if activated_keys.space then
         subjects.player_input:notify(events.interact)
      end

      if activated_keys.escape then
         subjects.player_input:notify(events.quit_game)
      end

      if activated_keys.p then
         subjects.player_input:notify(events.toggle_game_pause)
      end
   end
end
