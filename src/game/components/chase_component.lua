local Component = require("src.engine.ecs.component")

local ChaseComponent = prototype(
   Component("chase"),
   function(self, target_id, aggro_range)
      assertx.is_number(target_id)
      assertx.is_number(aggro_range)

      self.aggro_range = aggro_range
      self.target_id = target_id
      self.time_at_last_movement = 0
      self.time_between_movements = 1
   end
)

return ChaseComponent
