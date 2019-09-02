local create_render_ui = require("game.systems.create_render_ui")
local create_render_by_component = require("game.systems.create_render_by_component")
local create_tileset = require("game.render.create_tileset")
local components = require("game.entity.components")

local function set_background_color(entity_manager)
   local input_entity_id = entity_manager:get_unique_component(components.input)
   local input_position_c = entity_manager:get_component(input_entity_id, components.position)
   if input_position_c.level == "aboveground" then
      love.graphics.setBackgroundColor(9 / 256, 73  / 256, 63 / 256)
   else
      love.graphics.setBackgroundColor(25 / 256, 16  / 256, 46 / 256)
   end
end

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

         set_background_color(entity_manager)
         render_by_component()
         render_ui()
      end
   end
end
