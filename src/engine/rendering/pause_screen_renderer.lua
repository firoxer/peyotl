local PauseScreenRenderer = prototype(function(self, rendering_config)
   self._window_width =
      rendering_config.window.width
      * rendering_config.tiles.size
      * rendering_config.tiles.scale
   self._window_height =
      rendering_config.window.height
      * rendering_config.tiles.size
      * rendering_config.tiles.scale
end)

local PAUSE_SCREEN_COLOR = { 22 / 255, 22 / 255, 29 / 255 } -- Eigengrau

function PauseScreenRenderer:render()
   love.graphics.setColor(PAUSE_SCREEN_COLOR)
   love.graphics.rectangle("fill", 0, 0, self._window_width, self._window_height)

   print(self._window_height)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.printf(
      "paused",
      0,
      self._window_height / 2 - 10,
      self._window_width,
      "center"
   )
end

return PauseScreenRenderer