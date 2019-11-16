local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function generate_monsters(entity_manager, level_name, level_config)
   local walkable_points = {}
   for _, position_c in entity_manager:iterate("position") do
      table.insert(walkable_points, position_c.point)
   end

   table.shuffle(walkable_points)

   if #walkable_points < level_config.monsters.n then
      error("too few walkable tiles for monsters")
   end

   local player_entity_id = entity_manager:get_unique_component("input")

   for i = 1, level_config.monsters.n do
      local point = walkable_points[i % #walkable_points]

      local monster_id = entity_manager:new_entity_id()
      entity_manager:add_component(monster_id, create_component.attack(level_config.monsters.damage, 1, 0))
      entity_manager:add_component(monster_id, create_component.position(level_name, point))
      entity_manager:add_component(monster_id, create_component.collision())
      entity_manager:add_component(monster_id, create_component.chase(player_entity_id))
      entity_manager:add_component(monster_id, create_component.render(tileset_quad_names.monster, 2))
   end
end

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      if level_config.monsters then
         generate_monsters(entity_manager, level_name, level_config)
      end
   end
end
