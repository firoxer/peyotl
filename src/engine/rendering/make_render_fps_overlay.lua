local LINE_WIDTH = 5
local BUFFER_SIZE = 100
local TARGET_FPS = 60

-- This is super rudimentary
return function(rendering_config)
   assertx.is_table(rendering_config)

   local right_edge =
      rendering_config.window.width
      * rendering_config.tiles.size
      * rendering_config.tiles.scale
   local bottom_edge =
      rendering_config.window.height
      * rendering_config.tiles.size
      * rendering_config.tiles.scale

   local fps_buffer = {}
   local last_run_at = love.timer.getTime()
   return function()
      local current_time = love.timer.getTime()
      table.insert(fps_buffer, 1, 1 / (current_time - last_run_at))
      last_run_at = current_time

      if #fps_buffer > BUFFER_SIZE then
         table.remove(fps_buffer)
      end

      love.graphics.setLineWidth(LINE_WIDTH)
      love.graphics.setLineStyle("rough")

      love.graphics.setColor(0, 1, 0, 0.2)

      love.graphics.line(
         right_edge - (BUFFER_SIZE * LINE_WIDTH),
         bottom_edge - (TARGET_FPS * LINE_WIDTH),
         right_edge,
         bottom_edge - (TARGET_FPS * LINE_WIDTH)
      )

      for index, fps in ipairs(fps_buffer) do
         if fps >= TARGET_FPS then
            love.graphics.setColor(0, 1, 0, 0.2)
         else
            love.graphics.setColor(1, 0, 0, 0.4)
         end

         love.graphics.line(
            right_edge - (index * LINE_WIDTH),
            bottom_edge,
            right_edge - (index * LINE_WIDTH),
            bottom_edge - (fps * LINE_WIDTH)
         )
      end
   end
end


