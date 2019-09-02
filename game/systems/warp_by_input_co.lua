local components = require("game.entity.components")
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
         local input_entity_id = entity_manager:get_unique_component(components.input)

         local position_c = entity_manager:get_component(input_entity_id, components.position)
         local render_c = entity_manager:get_component(input_entity_id, components.render)

         local new_level = position_c.level == "aboveground" and "underground" or "aboveground"
         entity_manager:update_component(input_entity_id, position_c, { level = new_level })
         entity_manager:update_component(input_entity_id, render_c, { tileset_quad_name = new_level .. "_player" })

         do_warp = false
      end
   end
end
