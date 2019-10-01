local make_render_by_component = require("game.render.make_render_by_component")
local make_render_ui = require("game.render.make_render_ui")
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

   local render_by_component =
      make_render_by_component(rendering_config, levels_config, entity_manager, tileset)
   local render_ui =
      make_render_ui(rendering_config, entity_manager)

   return function()
      render_by_component()
      render_ui()
   end
end
