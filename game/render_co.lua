local render_by_component_co = require("game.render.render_by_component_co")
local render_ui_co = require("game.render.render_ui_co")
local create_tileset = require("game.render.create_tileset")

return function(rendering_config, levels_config, entity_manager)
   local window_width = rendering_config.window_width
   local window_height = rendering_config.window_height
   local tile_size = rendering_config.tile_size
   local scale = rendering_config.scale

   love.window.setMode(
      window_width * tile_size * scale,
      window_height * tile_size * scale,
      { vsync = false }
   )

   local tileset = create_tileset(rendering_config)

   local render_by_component = coroutine.wrap(render_by_component_co)
   local render_ui = coroutine.wrap(render_ui_co)

   render_by_component(rendering_config, levels_config, entity_manager, tileset)
   render_ui(rendering_config, entity_manager)

   while true do
      coroutine.yield()

      render_by_component()
      render_ui()
   end
end
