local component_names = require("game.entity.component_names")

return function(_, entity_manager)
   return function()
      for entity_id, health_c in entity_manager:iterate(component_names.health) do
         if health_c.amount <= 0 then
            entity_manager:remove_entity(entity_id)
         end
      end
   end
end
