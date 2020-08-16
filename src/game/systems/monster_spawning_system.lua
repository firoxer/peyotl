local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

local MonsterSpawningSystem = prototype(function(self, level_config, entity_manager)
   self._level_config = level_config
   self._entity_manager = entity_manager
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
   entity_manager:add_component(id, components.attack(self._level_config.monsters.damage, 1))
   entity_manager:add_component(id, components.position(position_c.point))
   entity_manager:add_component(id, components.collision())
   entity_manager:add_component(id, components.monster())
   entity_manager:add_component(id, components.render(tile_names.monster, 2))
   entity_manager:add_component(id, components.chase(spawning_c.chase_target_id, self._level_config.monsters.aggro_range))
end

function MonsterSpawningSystem:run()
   if not self._level_config.monsters or not self._level_config.monsters.spawning then
      return
   end

   local too_many_monsters = self:_count_monsters() >= self._level_config.monsters.max_n
   if too_many_monsters then
      return
   end

   local current_time = love.timer.getTime()
   for tile_id, spawning_c in self._entity_manager:iterate("monster_spawning") do
      local enough_time_elapsed =
         spawning_c.time_at_last_spawn + self._level_config.monsters.spawning.seconds_per_spawn
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