local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function spawn_monster(em, level_config, spawning_tile_id, spawning_c, level_name)
   local position_c = em:get_component(spawning_tile_id, "position")

   local id = em:new_entity_id()
   em:add_component(id, create_component.attack(level_config.monsters.damage, 1))
   em:add_component(id, create_component.position(position_c.point))
   em:add_component(id, create_component.collision())
   em:add_component(id,
      create_component.chase(spawning_c.chase_target_id, level_config.monsters.aggro_range)
   )

   local tileset_quad_name
   if level_name == "dungeon" then
      tileset_quad_name = tileset_quad_names.dungeon_monster
   elseif level_name == "temple" then
      tileset_quad_name = tileset_quad_names.temple_monster
   end
   em:add_component(id, create_component.render(tileset_quad_name, 2))
end

return function(level_config, em, level_name)
   return function()
      -- TODO: Return a noop function instead
      if not level_config.monsters or not level_config.monsters.spawning then
         return
      end

      local current_time = love.timer.getTime()
      for tile_id, spawning_c in em:iterate("monster_spawning") do
         if spawning_c.time_at_last_spawn + level_config.monsters.spawning.seconds_per_spawn < current_time then
            spawn_monster(em, level_config, tile_id, spawning_c, level_name)
            em:update_component(tile_id, "monster_spawning", {
               time_at_last_spawn = current_time
            })
         end
      end
   end
end