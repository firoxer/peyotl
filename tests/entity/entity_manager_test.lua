local EntityManager = require("game.entity.entity_manager")
local create_component = require("game.entity.create_component")

do
   local em = EntityManager()
   assert(type(em:new_entity_id()) == "number")
end

do
   local em = EntityManager()
   local id = em:new_entity_id()
   em:register_entity_id(id, "test")
   assert(em:get_registered_entity_id("test") == id)
end

do
   local em = EntityManager()
   local id = em:new_entity_id()
   local component = create_component.camera()
   em:add_component(id, component)
   assert(em:has_component(id, "camera") == true)
end
