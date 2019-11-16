return function(levels_config, entity_manager)
   return function()
      local input_entity_id = entity_manager:get_unique_component("input")
      local input_position_c = entity_manager:get_component(input_entity_id, "position")

      love.graphics.clear(levels_config[input_position_c.level].background_color)
   end
end