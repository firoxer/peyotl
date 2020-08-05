local EntityManager = require("src.engine.ecs.entity_manager")

do
   local em = EntityManager({})
   assert(type(em:new_entity_id()) == "number")
end

do
   local em = EntityManager({ "test_component" })
   local id = em:new_entity_id()
   local component = { name = "test_component" }
   em:add_component(id, component)
   assert(em:has_component(id, "test_component") == true)
end
