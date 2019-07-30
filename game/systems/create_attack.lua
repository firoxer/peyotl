local Point = require("game.data_structures.point")
local components = require("game.entity.components")

return function(_, entity_manager)
   return function()
      while true do
         local dt = coroutine.yield()

         local attackable_positions = {}
         for entity_id, _, position_c in entity_manager:iterate(components.health, components.position) do
            attackable_positions[entity_id] = position_c
         end

         for attacking_entity_id, attack_c, attacking_position_c in entity_manager:iterate(components.attack, components.position) do
            entity_manager:update_component(attacking_entity_id, attack_c, {
               time_since_last_attack = attack_c.time_since_last_attack + dt
            })

            if attack_c.time_since_last_attack > 1 then
               for attacked_entity_id, attacked_position_c in pairs(attackable_positions) do
                  if Point.chebyshev_distance(attacking_position_c.point, attacked_position_c.point) == 1 then
                     local health_c = entity_manager:get_component(attacked_entity_id, components.health)
                     entity_manager:update_component(attacked_entity_id, health_c, {
                        amount = health_c.amount - attack_c.amount
                     })
                     entity_manager:update_component(attacking_entity_id, attack_c, {
                        time_since_last_attack = 0
                     })
                  end
               end
            end
         end
      end
   end
end
