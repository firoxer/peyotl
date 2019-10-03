local Set = require("game.data_structures.set")
local Subject = require("game.event.subject")
local events = require("game.event.events")

local PlayerInput = {}

function PlayerInput:_bind_to_love()
   love.keypressed = function(key)
      if self._key_cooldowns[key] == nil then
         log.debug("key pressed with no action bound: " .. key)
         return
      end

      self._pressed_keys:add(key)
   end

   love.keyreleased = function(key)
      self._pressed_keys:remove(key)
   end
end

function PlayerInput:tick(dt)
   self._cooldown_left = self._cooldown_left - dt

   if self._cooldown_left > 0 or self._pressed_keys:is_empty() then
      return
   end

   local pressed_keys = self._pressed_keys

   for key in pressed_keys:pairs() do
      self._cooldown_left =
         self._cooldown_left < self._key_cooldowns[key]
            and self._key_cooldowns[key]
            or self._cooldown_left
   end

   if pressed_keys:contains("w") then
      if pressed_keys:contains("a") then
         self.subject:notify(events.move_nw)
      elseif pressed_keys:contains("d") then
         self.subject:notify(events.move_ne)
      else
         self.subject:notify(events.move_n)
      end
   elseif pressed_keys:contains("s") then
      if pressed_keys:contains("a") then
         self.subject:notify(events.move_sw)
      elseif pressed_keys:contains("d") then
         self.subject:notify(events.move_se)
      else
         self.subject:notify(events.move_s)
      end
   elseif pressed_keys:contains("a") then
      self.subject:notify(events.move_w)
   elseif pressed_keys:contains("d") then
      self.subject:notify(events.move_e)
   end

   if pressed_keys:contains("c") then
      self.subject:notify(events.warp)
   end

   if pressed_keys:contains("space") then
      self.subject:notify(events.interact)
   end

   if pressed_keys:contains("escape") then
      self.subject:notify(events.quit_game)
   end

   if pressed_keys:contains("p") then
      self.subject:notify(events.toggle_game_pause)
   end
end

return {
   new = function(player_input_config)
      local short_tick = player_input_config.keyboard_short_tick_s
      local long_tick = player_input_config.keyboard_long_tick_s

      local instance = instantiate(PlayerInput, {
         subject = Subject.new(),

         _key_cooldowns = {
            escape = long_tick,
            q = long_tick,

            p = long_tick,
            space = long_tick,
            c = long_tick,

            w = short_tick,
            a = short_tick,
            s = short_tick,
            d = short_tick,
         },

         _cooldown_left = 0,
         _pressed_keys = Set.new(),
      })

      instance:_bind_to_love()

      return instance
   end
}
