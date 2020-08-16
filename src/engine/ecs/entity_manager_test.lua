local EntityManager = require("src.engine.ecs.entity_manager")

do
   local entity_manager = EntityManager({})
   assert(type(entity_manager:new_entity_id()) == "number")
end

do
   local entity_manager = EntityManager({ "test_component" })
   local id = entity_manager:new_entity_id()
   local component = { name = "test_component" }
   entity_manager:add_component(id, component)
   assert(entity_manager:has_component(id, "test_component") == true)
end
