local create_component = require("game.entity.create_component")
local events = require("game.event.events")

return function(player_input)
   local do_warp = false
   player_input.subject:subscribe(events.warp, function()
      do_warp = true
   end)

   return function(game_state)
      if not do_warp then
         return
      end

      local temple_em = game_state.levels.temple.entity_manager
      local temple_player_entity_id = temple_em:get_registered_entity_id("player")

      local dungeon_em = game_state.levels.dungeon.entity_manager
      local dungeon_player_entity_id = dungeon_em:get_registered_entity_id("player")

      if game_state.current_level == "temple" then
         temple_em:remove_component(temple_player_entity_id, "input")
         dungeon_em:add_component(dungeon_player_entity_id, create_component.input())
         game_state.current_level = "dungeon"
      elseif game_state.current_level == "dungeon" then
         dungeon_em:remove_component(dungeon_player_entity_id, "input")
         temple_em:add_component(temple_player_entity_id, create_component.input())
         game_state.current_level = "temple"
      else
         error("unknown level to warp from: " .. game_state.current_level)
      end

      do_warp = false
   end
end
