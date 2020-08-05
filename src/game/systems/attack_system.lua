local AttackSystem = {}

local chebyshev_distance = ds.Point.chebyshev_distance
local function close_enough(pos_a, pos_b, range)
   return chebyshev_distance(pos_a.point, pos_b.point) <= range
end

function AttackSystem:initialize(_, em)
   self._entity_manager = em

   self:_track_attackable_positions()
end

function AttackSystem:_track_attackable_positions()
   self._attackable_positions = {}

   self._entity_manager.event_subject:subscribe(
      self._entity_manager.event_subject.events.component_added,
      function(event_data)
         if event_data.component_name == "collision" then
            self._attackable_positions = {}
            for entity_id, _, position_c in self._entity_manager:iterate("health", "position") do
               self._attackable_positions[entity_id] = position_c
            end
         end
      end
   )
end

function AttackSystem:run()
   local em = self._entity_manager

   local current_time = love.timer.getTime()
   for atk_entity_id, atk_c, atk_position_c in em:iterate("attack", "position") do
      if atk_c.time_at_last_attack + atk_c.time_between_attacks >= current_time then
         goto continue
      end

      for atkd_entity_id, atkd_position_c in pairs(self._attackable_positions) do
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

local prototype = prototypify(AttackSystem)
return prototype