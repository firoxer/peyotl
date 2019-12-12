local EntityManager = require("game.entity.entity_manager")
local generate_altars = require("game.generate.generate_altars")

local levels_config = {
   level_1 = {
      altar = false,
   },

   level_2 = {
      altar = true,
   },
}

do
   local em = EntityManager.new()

   em:register_entity_id(em:new_entity_id(), "altar_1")
   em:register_entity_id(em:new_entity_id(), "altar_2")
   em:register_entity_id(em:new_entity_id(), "altar_3")
   em:register_entity_id(em:new_entity_id(), "altar_4")
   generate_altars(em, levels_config)

   local position_component_n = 0
   for _ in em:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end

