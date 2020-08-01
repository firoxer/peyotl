local events = require("game.event.events")
local make_chase = require("game.make_systems.chase")
local make_attack = require("game.make_systems.attack")
local make_death = require("game.make_systems.death")
local make_move_by_input = require("game.make_systems.move_by_input")
local make_spawn_monsters = require("game.make_systems.spawn_monsters")

return function(game_state, player_input)
   player_input.subject:subscribe(events.quit_game, function()
      game_state.status = "terminating"
   end)
   player_input.subject:subscribe(events.toggle_game_pause, function()
      game_state.status = game_state.status ~= "paused" and "paused" or "running"
   end)

   local level_config = game_state.config.level
   local em = game_state.entity_manager

   local chase = make_chase(level_config, em)
   local attack = make_attack(level_config, em)
   local death = make_death(level_config, em)
   local move_by_input = make_move_by_input(level_config, em, player_input)
   local spawn_monsters = make_spawn_monsters(level_config, em)

   em.subject:subscribe(events.entity_removed, function(event_data)
      local player_is_removed = em:has_component(event_data.entity_id, "player")
      if player_is_removed then
         game_state.status = "resetting"
      end
   end)

   return function(dt)
      player_input:tick(dt)

      chase(dt)
      attack(dt)
      death()
      move_by_input()
      spawn_monsters(dt)
   end
end
