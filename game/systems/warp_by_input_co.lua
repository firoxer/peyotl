local component_names = require("game.entity.component_names")
local events = require("game.event.events")
local subjects = require("game.event.subjects")

return function(_, entity_manager)
   local do_warp = false
   subjects.player_input:subscribe(function(event)
      if event == events.warp then
         do_warp = true
      end
   end)

   while true do
      coroutine.yield()

      if do_warp then
         local input_entity_id = entity_manager:get_unique_component(component_names.input)
         local position_c = entity_manager:get_component(input_entity_id, component_names.position)
         local new_level = position_c.level == "aboveground" and "underground" or "aboveground"
         entity_manager:update_component(input_entity_id, position_c, { level = new_level })

         do_warp = false
      end
   end
end
