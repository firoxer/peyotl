local component_names = require("game.entity.component_names")
local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(entity_manager, levels_config)
   for level_name, level in pairs(levels_config) do
      if not level.monsters then
         goto continue
      end

      local walkable_points = {}
      for _, position_c in entity_manager:iterate(component_names.position) do
         table.insert(walkable_points, position_c.point)
      end

      table.shuffle(walkable_points)

      if #walkable_points < levels_config[level_name].monsters.n then
         error("too few walkable tiles for monsters")
      end

      local player_entity_id = entity_manager:get_unique_component(component_names.input)
      local player_position_c = entity_manager:get_component(player_entity_id, component_names.position)

      for i = 1, levels_config[level_name].monsters.n do
         local point = walkable_points[i % #walkable_points]

         local monster_id = entity_manager:new_entity_id()
         entity_manager:add_component(monster_id, create_component.attack(levels_config[level_name].monsters.damage, 1, 0))
         entity_manager:add_component(monster_id, create_component.position(level_name, point))
         entity_manager:add_component(monster_id, create_component.collision())
         entity_manager:add_component(monster_id, create_component.chase(player_position_c))
         entity_manager:add_component(monster_id, create_component.render(tileset_quad_names.underground_monster, 1))
      end

      ::continue::
   end
end
