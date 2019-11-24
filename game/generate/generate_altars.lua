local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function generate_altar(entity_manager, level_name, point)
   local altar_id = entity_manager:new_entity_id()
   entity_manager:add_component(altar_id, create_component.position(level_name, point))
   entity_manager:add_component(altar_id, create_component.render(tileset_quad_names.temple_altar, 1))
end

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      if level_config.altar then
         local altar_1_id = entity_manager:get_registered_entity_id("altar_1")
         entity_manager:add_component(altar_1_id, create_component.position(level_name, ds.Point.new(15, 4)))
         entity_manager:add_component(altar_1_id, create_component.render(tileset_quad_names.temple_altar, 1))

         local altar_2_id = entity_manager:get_registered_entity_id("altar_2")
         entity_manager:add_component(altar_2_id, create_component.position(level_name, ds.Point.new(15, 5)))
         entity_manager:add_component(altar_2_id, create_component.render(tileset_quad_names.temple_altar, 1))

         local altar_3_id = entity_manager:get_registered_entity_id("altar_3")
         entity_manager:add_component(altar_3_id, create_component.position(level_name, ds.Point.new(16, 4)))
         entity_manager:add_component(altar_3_id, create_component.render(tileset_quad_names.temple_altar, 1))

         local altar_4_id = entity_manager:get_registered_entity_id("altar_4")
         entity_manager:add_component(altar_4_id, create_component.position(level_name, ds.Point.new(16, 5)))
         entity_manager:add_component(altar_4_id, create_component.render(tileset_quad_names.temple_altar, 1))
      end
   end
end