local Component = require("src.engine.ecs.component")

local MonsterSpawningComponent = prototype(
   Component("monster_spawning"),
   function(self, chase_target_id, time_at_last_spawn)
      assertx.is_number(chase_target_id)
      assertx.is_number_or_nil(time_at_last_spawn)

      self.chase_target_id = chase_target_id
      self.time_at_last_spawn = time_at_last_spawn or 0
   end
)

return MonsterSpawningComponent
