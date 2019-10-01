local Point = require("game.data_structures.point")
local component_names = require("game.entity.component_names")
local events = require("game.event.events")

local ATTACK_RANGE = 1

return function(_, entity_manager)
   local attackable_positions = nil

   entity_manager.subject:subscribe(function(event, data)
      if event == events.component_added and data.component_name == component_names.collision then
         attackable_positions = {}
         for entity_id, _, position_c in entity_manager:iterate(component_names.health, component_names.position) do
            attackable_positions[entity_id] = position_c
         end
      end
   end)

   return function(dt)
      for atk_entity_id, atk_c, atk_position_c
            in entity_manager:iterate(component_names.attack, component_names.position) do
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

               if Point.chebyshev_distance(atk_position_c.point, atkd_position_c.point) ~= ATTACK_RANGE then
                  goto continue
               end

               local atkd_health_c = entity_manager:get_component(atkd_entity_id, component_names.health)
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
