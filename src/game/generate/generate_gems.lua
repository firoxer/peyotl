return function(gem_config, entity_manager, components, sprite_quads)
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
      entity_manager:add_component(gem_id, components.Position(point))
      local gem_quad =
         love.math.random() > 0.5
            and sprite_quads.gem1
            or sprite_quads.gem2
      entity_manager:add_component(gem_id, components.Sprite(gem_quad, 1))
   end
end
