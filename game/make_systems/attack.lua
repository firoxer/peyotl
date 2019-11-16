local events = require("game.event.events")

local chebyshev_distance = ds.Point.chebyshev_distance

local ATTACK_RANGE = 1

return function(_, entity_manager)
   local attackable_positions = nil

   entity_manager.subject:subscribe(events.component_added, function(event_data)
      if event_data.component_name == "collision" then
         attackable_positions = {}
         for entity_id, _, position_c in entity_manager:iterate("health", "position") do
            attackable_positions[entity_id] = position_c
         end
      end
   end)

   return function(dt)
      for atk_entity_id, atk_c, atk_position_c
            in entity_manager:iterate("attack", "position") do
         -- No need to update if already high enough
         if atk_c.time_since_last_attack <= atk_c.time_between_attacks then
            entity_manager:update_component(atk_entity_id, atk_c, {
               time_since_last_attack = atk_c.time_since_last_attack + dt
            })
         end

         if atk_c.time_since_last_attack > atk_c.time_between_attacks then
            for atkd_entity_id, atkd_position_c in pairs(attackable_positions) do
               if atk_position_c.level ~= atkd_position_c.level then
                  goto continue
               end

               if chebyshev_distance(atk_position_c.point, atkd_position_c.point) ~= ATTACK_RANGE then
                  goto continue
               end

               local atkd_health_c = entity_manager:get_component(atkd_entity_id, "health")
               entity_manager:update_component(atkd_entity_id, atkd_health_c, {
                  amount = atkd_health_c.amount - atk_c.amount
               })
               entity_manager:update_component(atk_entity_id, atk_c, {
                  time_since_last_attack = 0
               })

               ::continue::
            end
         end
      end
   end
end
