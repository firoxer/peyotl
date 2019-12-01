local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function spawn_monster(entity_manager, level_name, level_config, spawning_tile_id, spawning_c)
   local position_c = entity_manager:get_component(spawning_tile_id, "position")

   local monster_id = entity_manager:new_entity_id()
   entity_manager:add_component(monster_id, create_component.attack(level_config.monsters.damage, 1, 0))
   entity_manager:add_component(monster_id, create_component.position(level_name, position_c.point))
   entity_manager:add_component(monster_id, create_component.collision())
   entity_manager:add_component(monster_id, create_component.chase(spawning_c.chase_target_id))
   entity_manager:add_component(monster_id, create_component.render(tileset_quad_names.monster, 2))
end

return function(levels_config, entity_manager)
   return function(dt)
      local spawning_cs_by_id_by_level = {} -- TODO: Use caching

      for level_name in pairs(levels_config) do
         spawning_cs_by_id_by_level[level_name] = {}
      end
      for spawning_tile_id, spawning_c, position_c in entity_manager:iterate("monster_spawning", "position") do
         spawning_cs_by_id_by_level[position_c.level][spawning_tile_id] = spawning_c
      end

      for level_name, level_config in pairs(levels_config) do
         if not level_config.monsters or not level_config.monsters.spawning then
            goto continue
         end

         local spawning_cs_by_id = spawning_cs_by_id_by_level[level_name]

         if not spawning_cs_by_id then
            log.error("no tiles good for spawning in a level with spawning enabled: " .. level_name)
            goto continue
         end

         for tile_id, spawning_c in pairs(spawning_cs_by_id) do
            spawning_c.time_since_last_spawn = spawning_c.time_since_last_spawn + dt

            if spawning_c.time_since_last_spawn > level_config.monsters.spawning.seconds_per_spawn then
               spawn_monster(entity_manager, level_name, level_config, tile_id, spawning_c)
               spawning_c.time_since_last_spawn = 0
            end
         end

         ::continue::
      end
   end
end