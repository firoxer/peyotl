local UiRenderer = prototype(function(self, rendering_config, entity_manager)
   assertx.is_table(rendering_config)
   assertx.is_instance_of("engine.ecs.EntityManager", entity_manager)

   self._ui_unit =
      rendering_config.window.width / 10
   self._window_real_width =
      rendering_config.window.width * rendering_config.tiles.size * rendering_config.tiles.scale
   self._window_real_height =
      rendering_config.window.height * rendering_config.tiles.size * rendering_config.tiles.scale
   self._entity_manager = entity_manager
end)

function UiRenderer:render()
   -- Render input entity (player) stats
   local input_entity_id = self._entity_manager:get_unique_component("input")
   local input_entity_health_c = self._entity_manager:get_component(input_entity_id, "health")

   love.graphics.setColor(0.9, 0.34, 0.1)
   love.graphics.rectangle(
      "fill",
      self._ui_unit,
      self._window_real_height - self._ui_unit * 3,
      ((self._window_real_width / 2) - self._ui_unit * 2)
         * (input_entity_health_c.amount / 100),
      self._ui_unit * 2
   )
end

return UiRenderer