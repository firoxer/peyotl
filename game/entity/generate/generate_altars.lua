local create_component = require("game.entity.create_component")
local measure_time = require("game.util.measure_time")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(em, level_config)
   if not level_config.altar then
      return
   end

   measure_time.start()

   local altar_1_id = em:get_registered_entity_id("altar_1")
   local altar_2_id = em:get_registered_entity_id("altar_2")
   local altar_3_id = em:get_registered_entity_id("altar_3")
   local altar_4_id = em:get_registered_entity_id("altar_4")

   if altar_1_id == nil or altar_2_id == nil or altar_3_id == nil or altar_4_id == nil then
      log.error("could not get entity ID for one or more altars, skipping altar generation")
      return
   end

   em:add_component(altar_1_id, create_component.position(ds.Point.new(15, 4)))
   em:add_component(altar_1_id, create_component.render(tileset_quad_names.temple_altar, 1))
   em:add_component(altar_1_id, create_component.chaseable())

   em:add_component(altar_2_id, create_component.position(ds.Point.new(15, 5)))
   em:add_component(altar_2_id, create_component.render(tileset_quad_names.temple_altar, 1))
   em:add_component(altar_2_id, create_component.chaseable())

   em:add_component(altar_3_id, create_component.position(ds.Point.new(16, 4)))
   em:add_component(altar_3_id, create_component.render(tileset_quad_names.temple_altar, 1))
   em:add_component(altar_3_id, create_component.chaseable())

   em:add_component(altar_4_id, create_component.position(ds.Point.new(16, 5)))
   em:add_component(altar_4_id, create_component.render(tileset_quad_names.temple_altar, 1))
   em:add_component(altar_4_id, create_component.chaseable())

   measure_time.stop_and_log("altar generated")
end