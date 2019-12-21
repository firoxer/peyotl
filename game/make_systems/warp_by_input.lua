local events = require("game.event.events")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(_, entity_manager, player_input)
   local do_warp = false
   player_input.subject:subscribe(events.warp, function()
      do_warp = true
   end)

   return function()
      if do_warp then
         local player_entity_id = entity_manager:get_registered_entity_id("player")

         local position_c = entity_manager:get_component(player_entity_id, "position")

         if position_c.level == "temple" then
            entity_manager:update_component(player_entity_id, "position", { level = "dungeon" })
            entity_manager:update_component(player_entity_id, "render", { tileset_quad_name = tileset_quad_names.player_dungeon, 2 })
         elseif position_c.level == "dungeon" then
            entity_manager:update_component(player_entity_id, "position", { level = "temple" })
            entity_manager:update_component(player_entity_id, "render", { tileset_quad_name = tileset_quad_names.player_temple, 2 })
         else
            error("unknown level in player position component: " .. position_c.level)
         end

         do_warp = false
      end
   end
end
