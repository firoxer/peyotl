local component_names = require("game.entity.component_names")
local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function generate_gems(entity_manager, level_name, level_config)
   local walkable_points = {}
   for position_id, position_c in entity_manager:iterate(component_names.position) do
      if position_c.level == level_name
            and not entity_manager:has_component(position_id, component_names.collision) then
         table.insert(walkable_points, position_c.point)
      end
   end

   table.shuffle(walkable_points)

   local gems_to_generate = math.floor(#walkable_points * level_config.gems.density)

   for i = 1, gems_to_generate do
      local point = walkable_points[i]

      local gem_id = entity_manager:new_entity_id()
      entity_manager:add_component(gem_id, create_component.position(level_name, point))
      entity_manager:add_component(gem_id, create_component.render(love.math.random() > 0.5 and tileset_quad_names.gem1 or tileset_quad_names.gem2, 1))
   end
end

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      if level_config.gems then
         generate_gems(entity_manager, level_name, level_config)
      end
    end
end