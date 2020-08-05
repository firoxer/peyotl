local DeathSystem = prototype(function(self, _, em)
   self._entity_manager = em
end)

function DeathSystem:run()
   for entity_id, health_c in self._entity_manager:iterate("health") do
      if health_c.amount <= 0 then
         self._entity_manager:remove_entity(entity_id)
      end
   end
end

return DeathSystem