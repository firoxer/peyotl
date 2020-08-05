local EventSubject = require("src.engine.event.event_subject")

local PlayerInput = {}

local events = tablex.identity({
   "move_n",
   "move_ne",
   "move_e",
   "move_se",
   "move_s",
   "move_sw",
   "move_w",
   "move_nw",

   "interact",

   "quit_game",
   "toggle_game_pause",
})

function PlayerInput:initialize(player_input_config)
   local short_tick = player_input_config.keyboard_short_tick_s
   local long_tick = player_input_config.keyboard_long_tick_s

   self.event_subject = EventSubject(events)

   self._key_cooldowns = {
      escape = long_tick,
      q = long_tick,

      p = long_tick,
      space = long_tick,
      c = long_tick,

      w = short_tick,
      a = short_tick,
      s = short_tick,
      d = short_tick,
   }

   self._cooldown_left = 0
   self._pressed_keys = ds.Set()

   self:_bind_to_love()
end

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
   assertx.is_number(dt)

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
         self.event_subject:notify(events.move_nw)
      elseif pressed_keys:contains("d") then
         self.event_subject:notify(events.move_ne)
      else
         self.event_subject:notify(events.move_n)
      end
   elseif pressed_keys:contains("s") then
      if pressed_keys:contains("a") then
         self.event_subject:notify(events.move_sw)
      elseif pressed_keys:contains("d") then
         self.event_subject:notify(events.move_se)
      else
         self.event_subject:notify(events.move_s)
      end
   elseif pressed_keys:contains("a") then
      self.event_subject:notify(events.move_w)
   elseif pressed_keys:contains("d") then
      self.event_subject:notify(events.move_e)
   end

   if pressed_keys:contains("space") then
      self.event_subject:notify(events.interact)
   end

   if pressed_keys:contains("escape") then
      self.event_subject:notify(events.quit_game)
   end

   if pressed_keys:contains("p") then
      self.event_subject:notify(events.toggle_game_pause)
   end
end

local prototype = prototypify(PlayerInput)
return prototype
