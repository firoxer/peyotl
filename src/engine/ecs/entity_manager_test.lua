local Component = require("src.engine.ecs.component")
local EntityManager = require("src.engine.ecs.entity_manager")

do
   local entity_manager = EntityManager({})
   assert(type(entity_manager:new_entity_id()) == "number")
end

do
   local TestComponent = prototype(Component("test_component"))

   local entity_manager = EntityManager({ TestComponent })

   local id = entity_manager:new_entity_id()
   entity_manager:add_component(id, TestComponent())

   assert(entity_manager:has_component(id, "test_component") == true)
end
