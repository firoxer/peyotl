local events = require("game.event.events")

local function track_attackable_positions(entity_manager)
   local attackable_positions = {}

   entity_manager.subject:subscribe(events.component_added, function(event_data)
      if event_data.component_name == "collision" then
         attackable_positions = {}
         for entity_id, _, position_c in entity_manager:iterate("health", "position") do
            attackable_positions[entity_id] = position_c
         end
      end
   end)

   return attackable_positions
end

local chebyshev_distance = ds.Point.chebyshev_distance
local function close_enough(pos_a, pos_b, range)
   return
      pos_a.level == pos_b.level
      and chebyshev_distance(pos_a.point, pos_b.point) <= range
end

return function(_, entity_manager)
   assertx.is_instance_of("entity.EntityManager", entity_manager)

   local attackable_positions = track_attackable_positions(entity_manager)

   return function()
      local current_time = love.timer.getTime()
      for atk_entity_id, atk_c, atk_position_c in entity_manager:iterate("attack", "position") do
         if atk_c.time_at_last_attack + atk_c.time_between_attacks >= current_time then
            goto continue
         end

         for atkd_entity_id, atkd_position_c in pairs(attackable_positions) do
            if close_enough(atk_position_c, atkd_position_c, atk_c.range) then
               local atkd_health_c = entity_manager:get_component(atkd_entity_id, "health")
               entity_manager:update_component(atkd_entity_id, "health", {
                  amount = atkd_health_c.amount - atk_c.amount
               })
               entity_manager:update_component(atk_entity_id, "attack", {
                  time_at_last_attack = current_time
               })
            end
         end

         ::continue::
      end
   end
end
