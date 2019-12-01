return function(rendering_config, entity_manager)
   local window_width = rendering_config.window_width
   local window_height = rendering_config.window_height
   local scale = rendering_config.scale
   local tile_size = rendering_config.tile_size


   return function()
      local camera_entity_position_c =
         entity_manager:get_component(entity_manager:get_unique_component("camera"), "position")
      local current_camera_x = camera_entity_position_c.point.x
      local current_camera_y = camera_entity_position_c.point.y

      local overlay = _G.game_debug.overlay

      if not overlay then
         log.debug("no debug overlay found")
         return
      end

      local draw = function(point, val)
         local offset_x = point.x - current_camera_x + (window_width / 2)
         local offset_y = point.y - current_camera_y + (window_height / 2)

         if type(val) == "number" then
            love.graphics.setColor(1 - val / 16, 0, 0, 0.2)
         elseif type(val) == "boolean" then
            if val == true then
               love.graphics.setColor(0, 1, 0, 0.2)
            else
               love.graphics.setColor(0, 0, 1, 0.2)
            end
         end
         love.graphics.rectangle(
            "fill",
            offset_x * tile_size * scale,
            offset_y * tile_size * scale,
            tile_size * scale,
            tile_size * scale
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
end

