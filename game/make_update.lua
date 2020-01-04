local events = require("game.event.events")
local make_chase = require("game.make_systems.chase")
local make_attack = require("game.make_systems.attack")
local make_death = require("game.make_systems.death")
local make_move_by_input = require("game.make_systems.move_by_input")
local make_warp_by_input = require("game.make_systems.warp_by_input")
local make_spawn_monsters = require("game.make_systems.spawn_monsters")

return function(game_state, player_input)
   player_input.subject:subscribe(events.quit_game, function()
      game_state.status = "terminating"
   end)
   player_input.subject:subscribe(events.toggle_game_pause, function()
      game_state.status = game_state.status ~= "paused" and "paused" or "running"
   end)

   local warp_by_input = make_warp_by_input(player_input)

   local updates_by_level = tablex.mappairs(game_state.levels, function(level_name, level)
      local chase = make_chase(level.config, level.entity_manager)
      local attack = make_attack(level.config, level.entity_manager)
      local death = make_death(level.config, level.entity_manager)
      local move_by_input = make_move_by_input(level.config, level.entity_manager, player_input)
      local spawn_monsters = make_spawn_monsters(level.config, level.entity_manager, level_name)

      level.entity_manager.subject:subscribe(events.entity_removed, function(event_data)
         if event_data.entity_id == level.entity_manager:get_registered_entity_id("player") then
            game_state.status = "resetting"
         end
      end)

      return function(dt)
         chase(dt)
         attack(dt)
         death()
         move_by_input()
         spawn_monsters(dt)
      end
   end)

   return function(dt)
      player_input:tick(dt)
      warp_by_input(game_state)
      updates_by_level[game_state.current_level](dt)
   end
end
