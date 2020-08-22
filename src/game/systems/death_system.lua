local System = require("src.engine.ecs.system")

local DeathSystem = prototype(System, function(self, _, entity_manager)
   self._entity_manager = entity_manager
end)

function DeathSystem:run()
   for entity_id, health_c in self._entity_manager:iterate("health") do
      if health_c.amount <= 0 then
         self._entity_manager:remove_entity(entity_id)
      end
   end
end

return DeathSystem