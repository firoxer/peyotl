local make_render_by_component = require("game.render.make_render_by_component")
local make_render_debug_overlay = require("game.render.make_render_debug_overlay")
local make_render_ui = require("game.render.make_render_ui")
local create_tileset = require("game.render.create_tileset")

return function(rendering_config, levels_config, entity_manager)
   local tile_size = rendering_config.tiles.size
   local tile_scale = rendering_config.tiles.scale

   love.window.setMode(
      rendering_config.window.width * tile_size * tile_scale,
      rendering_config.window.height * tile_size * tile_scale,
      { vsync = rendering_config.enable_vsync }
   )

   local tileset = create_tileset(tile_size)

   local render_by_component =
      make_render_by_component(rendering_config, levels_config, entity_manager, tileset)
   local render_ui =
      make_render_ui(rendering_config, entity_manager)

   if rendering_config.debug_overlay_enabled then
      local render_debug_overlay =
         make_render_debug_overlay(rendering_config, entity_manager)
      return function()
         render_by_component()
         render_ui()
         render_debug_overlay()
      end
   end

   return function()
      render_by_component()
      render_ui()
   end
end
