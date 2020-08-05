local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

return function(em, gem_config)
   local walkable_points = {}
   for position_id, position_c in em:iterate("position") do
      if not em:has_component(position_id, "collision") then
         table.insert(walkable_points, position_c.point)
      end
   end

   tablex.shuffle(walkable_points)

   local gems_to_generate = math.floor(#walkable_points * gem_config.density)

   for i = 1, gems_to_generate do
      local point = walkable_points[i]

      local gem_id = em:new_entity_id()
      em:add_component(gem_id, components.position(point))
      local gem_quad_name =
         love.math.random() > 0.5
            and tile_names.gem1
            or tile_names.gem2
      em:add_component(gem_id, components.render(gem_quad_name, 1))
   end
end
