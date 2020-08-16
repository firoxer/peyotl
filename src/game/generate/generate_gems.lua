local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

return function(entity_manager, gem_config)
   local walkable_points = {}
   for position_id, position_c in entity_manager:iterate("position") do
      if not entity_manager:has_component(position_id, "collision") then
         table.insert(walkable_points, position_c.point)
      end
   end

   tablex.shuffle(walkable_points)

   local gems_to_generate = math.floor(#walkable_points * gem_config.density)
   for i = 1, gems_to_generate do
      local point = walkable_points[i]

      local gem_id = entity_manager:new_entity_id()
      entity_manager:add_component(gem_id, components.position(point))
      local gem_quad_name =
         love.math.random() > 0.5
            and tile_names.gem1
            or tile_names.gem2
      entity_manager:add_component(gem_id, components.texture(gem_quad_name, 1))
   end
end
