--- Technically this should go under systems/ but this way it just makes more sense

return function(rendering_config, entity_manager)
   assertx.is_table(rendering_config)
   assertx.is_instance_of("engine.ecs.EntityManager", entity_manager)

   local ui_unit =
      rendering_config.window.width / 10
   local window_real_width =
      rendering_config.window.width * rendering_config.tiles.size * rendering_config.tiles.scale
   local window_real_height =
      rendering_config.window.height * rendering_config.tiles.size * rendering_config.tiles.scale

   return function()
      -- Render input entity (player) stats
      local input_entity_id = entity_manager:get_unique_component("input")
      local input_entity_health_c = entity_manager:get_component(input_entity_id, "health")

      love.graphics.setColor(0.9, 0.34, 0.1)
      love.graphics.rectangle(
         "fill",
         ui_unit,
         window_real_height - ui_unit * 3,
         ((window_real_width / 2) - ui_unit * 2) * (input_entity_health_c.amount / 100),
         ui_unit * 2
      )
   end
end
