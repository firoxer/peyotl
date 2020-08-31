local LINE_WIDTH = 5
local BUFFER_SIZE = 100
local TARGET_FPS = 60

-- This is super rudimentary
local FpsOverlayRenderer = prototype(function(self, rendering_config)
   self._window_right_edge =
      rendering_config.window.width
      * rendering_config.tiles.size
      * rendering_config.tiles.scale

   self._window_bottom_edge =
      rendering_config.window.height
      * rendering_config.tiles.size
      * rendering_config.tiles.scale

   self._fps_buffer = {}

   self._last_run_at = love.timer.getTime()
end)

function FpsOverlayRenderer:render()
   local current_time = love.timer.getTime()
   table.insert(self._fps_buffer, 1, 1 / (current_time - self._last_run_at))
   self._last_run_at = current_time

   if #self._fps_buffer > BUFFER_SIZE then
      table.remove(self._fps_buffer)
   end

   love.graphics.setLineWidth(LINE_WIDTH)
   love.graphics.setLineStyle("rough")

   love.graphics.setColor(0, 1, 0, 0.2)

   love.graphics.line(
      self._right_edge - (BUFFER_SIZE * LINE_WIDTH),
      self._bottom_edge - (TARGET_FPS * LINE_WIDTH),
      self._right_edge,
      self._bottom_edge - (TARGET_FPS * LINE_WIDTH)
   )

   for index, fps in ipairs(self._fps_buffer) do
      if fps >= TARGET_FPS then
         love.graphics.setColor(0, 1, 0, 0.2)
      else
         love.graphics.setColor(1, 0, 0, 0.4)
      end

      love.graphics.line(
         self._right_edge - (index * LINE_WIDTH),
         self._bottom_edge,
         self._right_edge - (index * LINE_WIDTH),
         self._bottom_edge - (fps * LINE_WIDTH)
      )
   end
end

return FpsOverlayRenderer