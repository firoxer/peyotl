local DebugOverlayRenderer = prototype(function(self, rendering_config, entity_manager)
   assertx.is_table(rendering_config)
   assertx.is_instance_of("engine.ecs.EntityManager", entity_manager)

   self._rendering_config = rendering_config
   self._entity_manager = entity_manager
end)

function DebugOverlayRenderer:render()
   local camera_entity_position_c =
      self._entity_manager:get_component(self._entity_manager:get_unique_component("camera"), "position")
   local current_camera_x = camera_entity_position_c.point.x
   local current_camera_y = camera_entity_position_c.point.y

   local overlay = _G.game_debug.overlay

   if not overlay then
      log.debug("no debug overlay found")
      return
   end

   local draw = function(point, val)
      local offset_x = point.x - current_camera_x + (self._rendering_config.window.width / 2)
      local offset_y = point.y - current_camera_y + (self._rendering_config.window.height / 2)

      if type(val) == "number" then
         love.graphics.setColor(1 - val / 16, 0, 0, 0.2)
      elseif type(val) == "boolean" then
         if val == true then
            love.graphics.setColor(0, 1, 0, 0.2)
         else
            love.graphics.setColor(0, 0, 1, 0.2)
         end
      end
      local tile_size = self._rendering_config.tiles.size
      local tile_scale = self._rendering_config.tiles.scale
      love.graphics.rectangle(
         "fill",
         offset_x * tile_size * tile_scale,
         offset_y * tile_size * tile_scale,
         tile_size * tile_scale,
         tile_size * tile_scale
      )
   end

   if overlay.pairs then
      for point, val in overlay:pairs() do
         draw(point, val)
      end
   else
      for point, val in pairs(overlay) do
         draw(point, val)
      end
   end
end

return DebugOverlayRenderer