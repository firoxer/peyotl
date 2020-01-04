local create_tileset = require("game.render.create_tileset")
local make_render_by_component = require("game.render.make_render_by_component")
local make_render_debug_overlay = require("game.render.make_render_debug_overlay")
local make_render_ui = require("game.render.make_render_ui")

return function(rendering_config, game_state)
   local tileset = create_tileset(rendering_config.tiles.size)

   local render_by_level = tablex.mappairs(game_state.levels, function(_, level)
      local render_by_component =
         make_render_by_component(rendering_config, level.config, level.entity_manager, tileset)
      local render_ui =
         make_render_ui(rendering_config, level.entity_manager)
      if rendering_config.debug_overlay_enabled then
         local render_debug_overlay =
            make_render_debug_overlay(rendering_config, level.entity_manager)
         return function()
            render_by_component()
            render_ui()
            render_debug_overlay()
         end
      else
         return function()
            render_by_component()
            render_ui()
         end
      end
   end)

   return function()
      render_by_level[game_state.current_level]()
   end
end
