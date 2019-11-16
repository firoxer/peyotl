local events = require("game.event.events")

return function(_, entity_manager, player_input)
   local do_warp = false
   player_input.subject:subscribe(events.warp, function()
      do_warp = true
   end)

   return function()
      if do_warp then
         local input_entity_id = entity_manager:get_unique_component("input")
         local position_c = entity_manager:get_component(input_entity_id, "position")
         local new_level = position_c.level == "temple" and "dungeon" or "temple"
         entity_manager:update_component(input_entity_id, position_c, { level = new_level })

         do_warp = false
      end
   end
end
