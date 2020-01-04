local create_component = require("game.entity.create_component")
local measure_time = require("game.util.measure_time")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(em, level_config)
   if not level_config.gems then
      return
   end

   measure_time.start()

   local walkable_points = {}
   for position_id, position_c in em:iterate("position") do
      if not em:has_component(position_id, "collision") then
         table.insert(walkable_points, position_c.point)
      end
   end

   tablex.shuffle(walkable_points)

   local gems_to_generate = math.floor(#walkable_points * level_config.gems.density)

   for i = 1, gems_to_generate do
      local point = walkable_points[i]

      local gem_id = em:new_entity_id()
      em:add_component(gem_id, create_component.position(point))
      -- FIXME: Correct quad names, this is not necessarily a dungeon
      local gem_quad_name =
         love.math.random() > 0.5
            and tileset_quad_names.dungeon_gem1
            or tileset_quad_names.dungeon_gem2
      em:add_component(gem_id, create_component.render(gem_quad_name, 1))
   end

   measure_time.stop_and_log("gems generated")
end