local components = require("game.entity.components")
local events = require("game.event.events")
local subjects = require("game.event.subjects")

return function(_, entity_manager)
   return function()
      local do_warp = false
      subjects.player_input:add_observer(function(event)
         if event == events.warp then
            do_warp = true
         end
      end)

      while true do
         coroutine.yield()

         if do_warp then
            for entity_id, _ in entity_manager:iterate(components.input) do
               local position_c = entity_manager:get_component(entity_id, components.position)
               local render_c = entity_manager:get_component(entity_id, components.render)

               local new_level = position_c.level == "aboveground" and "underground" or "aboveground"
               entity_manager:update_component(entity_id, position_c, { level = new_level })
               entity_manager:update_component(entity_id, render_c, { tileset_quad_name = new_level .. "_player" })
            end

            do_warp = false
         end
      end
   end
end
