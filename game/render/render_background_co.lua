local component_names = require("game.entity.component_names")

return function(levels_config, entity_manager)
   return coroutine.wrap(function()
      while true do
         local input_entity_id = entity_manager:get_unique_component(component_names.input)
         local input_position_c = entity_manager:get_component(input_entity_id, component_names.position)

         love.graphics.clear(levels_config[input_position_c.level].background_color)

         coroutine.yield()
      end
   end)
end