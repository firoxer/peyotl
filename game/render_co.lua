local render_ui_co = require("game.render.render_ui_co")
local render_by_component_co = require("game.render.render_by_component_co")
local create_tileset = require("game.render.create_tileset")
local component_names = require("game.entity.component_names")

local function set_background_color(entity_manager, levels_config)
   local input_entity_id = entity_manager:get_unique_component(component_names.input)
   local input_position_c = entity_manager:get_component(input_entity_id, component_names.position)
   love.graphics.setBackgroundColor(levels_config[input_position_c.level].background_color)
end

return function(rendering_config, levels_config, entity_manager)
   love.window.setMode(
      rendering_config.window_width * rendering_config.window_cell_size,
      rendering_config.window_height * rendering_config.window_cell_size
   )

   local tileset = create_tileset(rendering_config)

   local render_ui = coroutine.wrap(render_ui_co)
   render_ui(rendering_config, entity_manager)
   local render_by_component = coroutine.wrap(render_by_component_co)
   render_by_component(rendering_config, levels_config, entity_manager, tileset)

   while true do
      coroutine.yield()

      set_background_color(entity_manager, levels_config)
      render_by_component()
      render_ui()
   end
end
