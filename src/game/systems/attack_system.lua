local function close_enough(pos_a, pos_b, range)
   return ds.Point.chebyshev_distance(pos_a.point, pos_b.point) <= range
end

local AttackSystem = prototype(function(self, _, em)
   self._entity_manager = em
end)

function AttackSystem:run()
   local em = self._entity_manager

   local current_time = love.timer.getTime()
   for atk_entity_id, atk_c, atk_position_c in em:iterate("attack", "position") do
      if atk_c.time_at_last_attack + atk_c.time_between_attacks >= current_time then
         goto continue
      end

      local attackable_positions = {}
      for entity_id, _, position_c in self._entity_manager:iterate("health", "position") do
         attackable_positions[entity_id] = position_c
      end

      for atkd_entity_id, atkd_position_c in pairs(attackable_positions) do
         if close_enough(atk_position_c, atkd_position_c, atk_c.range) then
            local atkd_health_c = em:get_component(atkd_entity_id, "health")
            em:update_component(atkd_entity_id, "health", {
               amount = atkd_health_c.amount - atk_c.amount
            })
            em:update_component(atk_entity_id, "attack", {
               time_at_last_attack = current_time
            })
         end
      end

      ::continue::
   end
end

return AttackSystem