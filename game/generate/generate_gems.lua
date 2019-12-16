local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function generate_gems(entity_manager, level_name, gem_config)
   assertx.is_string(level_name)

   local walkable_points = {}
   for position_id, position_c in entity_manager:iterate("position") do
      if position_c.level == level_name
            and not entity_manager:has_component(position_id, "collision") then
         table.insert(walkable_points, position_c.point)
      end
   end

   tablex.shuffle(walkable_points)

   local gems_to_generate = math.floor(#walkable_points * gem_config.density)

   for i = 1, gems_to_generate do
      local point = walkable_points[i]

      local gem_id = entity_manager:new_entity_id()
      entity_manager:add_component(gem_id, create_component.position(level_name, point))
      local gem_quad_name = love.math.random() > 0.5 and tileset_quad_names.gem1 or tileset_quad_names.gem2
      entity_manager:add_component(gem_id, create_component.render(gem_quad_name, 1))
   end
end

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      if level_config.gems then
         generate_gems(entity_manager, level_name, level_config.gems)
      end
    end
end