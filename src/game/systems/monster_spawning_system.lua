local System = require("src.engine.ecs.system")

local MonsterSpawningSystem = prototype(System, function(self, world_config, entity_manager, components, sprite_quads)
   self._monster_config = world_config.monsters
   self._entity_manager = entity_manager
   self._components = components
   self._sprite_quads = sprite_quads
end)

function MonsterSpawningSystem:_count_monsters()
   local n = 0
   for _ in self._entity_manager:iterate("monster") do
      n = n + 1
   end

   return n
end

function MonsterSpawningSystem:_spawn_monster(spawning_tile_id, spawning_c)
   local entity_manager = self._entity_manager

   local position_c = entity_manager:get_component(spawning_tile_id, "position")

   local id = entity_manager:new_entity_id()
   entity_manager:add_component(id, self._components.Attack(self._monster_config.damage, 1))
   entity_manager:add_component(id, self._components.Position(position_c.point))
   entity_manager:add_component(id, self._components.Collision())
   entity_manager:add_component(id, self._components.Monster())
   entity_manager:add_component(id, self._components.Sprite(self._sprite_quads.monster1, 2))
   entity_manager:add_component(id, self._components.Chase(spawning_c.chase_target_id, self._monster_config.aggro_range))
end

function MonsterSpawningSystem:run()
   if not self._monster_config or not self._monster_config.spawning then
      return
   end

   local too_many_monsters = self:_count_monsters() >= self._monster_config.max_n
   if too_many_monsters then
      return
   end

   local current_time = love.timer.getTime()
   for tile_id, spawning_c in self._entity_manager:iterate("monster_spawning") do
      local enough_time_elapsed =
         spawning_c.time_at_last_spawn + self._monster_config.spawning.seconds_per_spawn
            < current_time
      if enough_time_elapsed then
         self:_spawn_monster(tile_id, spawning_c)
         self._entity_manager:update_component(tile_id, "monster_spawning", {
            time_at_last_spawn = current_time
         })
      end
   end
end

return MonsterSpawningSystem