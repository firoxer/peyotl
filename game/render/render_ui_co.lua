--- Technically this should go under systems/ but this way it just makes more sense

local components = require("game.entity.components")

--[[
--local PAUSE_SCREEN_COLOR = { 22, 22, 29 } -- Eigengrau
local function _render_pause_screen()
   love.graphics.setColor(PAUSE_SCREEN_COLOR)
   love.graphics.rectangle("fill", 0, 0, self._window_real_width, self._window_real_height)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.printf(
      "paused",
      0,
      self._window_real_height / 2 - 10,
      self._window_real_width,
      "center"
   )
end
--]]

return function(rendering_config, entity_manager)
   local ui_unit = rendering_config.window_width / 10
   local window_real_width = rendering_config.window_width * rendering_config.window_cell_size
   local window_real_height = rendering_config.window_height * rendering_config.window_cell_size

   while true do
      coroutine.yield()

      -- Render FPS
      love.graphics.setColor(1, 0, 1, 1)
      love.graphics.print(tostring(love.timer.getFPS()), 0, 0)

      -- Render input entity (player) stats
      local input_entity_id = entity_manager:get_unique_component(components.input)
      local input_entity_health_c = entity_manager:get_component(input_entity_id, components.health)

      love.graphics.setColor(hsl(0.05, 0.8, 0.5, 1))
      love.graphics.rectangle(
         "fill",
         ui_unit,
         window_real_height - ui_unit * 3,
         ((window_real_width / 2) - ui_unit * 2) * (input_entity_health_c.amount / 100),
         ui_unit * 2
      )
   end
end