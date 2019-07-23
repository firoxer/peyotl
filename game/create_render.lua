local create_render_ui = require("game.systems.create_render_ui")
local create_render_by_component = require("game.systems.create_render_by_component")
local create_tileset = require("game.render.create_tileset")

return function(rendering_config, levels_config, entity_manager)
   return function()
      love.window.setMode(
         rendering_config.window_width * rendering_config.window_cell_size,
         rendering_config.window_height * rendering_config.window_cell_size
      )

      local tileset = create_tileset(rendering_config)

      local render_ui = coroutine.wrap(
         create_render_ui(rendering_config, entity_manager)
      )
      local render_by_component = coroutine.wrap(
         create_render_by_component(rendering_config, levels_config, entity_manager, tileset)
      )

      while true do
         coroutine.yield()
         render_by_component()
         render_ui()
      end
   end
end
