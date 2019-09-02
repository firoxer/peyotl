local Matrix = require("game.data_structures.matrix")
local Pathfinder = require("game.pathfinder")
local Point = require("game.data_structures.point")
local components = require("game.entity.components")
local subjects = require("game.event.subjects")
local events = require("game.event.events")

return function(levels_config, entity_manager)
   local collision_matrices = {}
   for level_name, level_config in pairs(levels_config) do
      local matrix = Matrix.new()
      for y = 1, level_config.height do
         for x = 1, level_config.width do
            matrix:set(Point.new(x, y), false)
         end
      end
      collision_matrices[level_name] = matrix
   end

   subjects.entity_manager:subscribe(function(event, data)
      if event == events.component_added and data.component_name == components.collision then
         local position_c = entity_manager:get_component(data.id, components.position)
         collision_matrices[position_c.level]:set(position_c.point, true)
      end
   end)

   subjects.entity_manager:subscribe(function(event, data)
      if event == events.component_updated and data.component_name == components.position then
         if entity_manager:has_component(data.id, components.collision) then
            local position_c = entity_manager:get_component(data.id, components.position)
            collision_matrices[position_c.level]:set(data.old_fields.point, false)
            collision_matrices[position_c.level]:set(data.new_fields.point, true)
         end
      end
   end)

   while true do
      local dt = coroutine.yield()

      local pathfinders_by_chase_target = {}
      for entity_id, chase_c, position_c in entity_manager:iterate(components.chase, components.position) do
         entity_manager:update_component(entity_id, chase_c, {
            time_since_last_movement = chase_c.time_since_last_movement + dt
         })

         if chase_c.time_since_last_movement < 1 then
            goto continue
         end

         local aggro_range = levels_config[position_c.level].monsters.aggro_range
         if Point.chebyshev_distance(position_c.point, chase_c.target.point) > aggro_range then
            goto continue
         end

         if not pathfinders_by_chase_target[chase_c.target] then
            pathfinders_by_chase_target[chase_c.target] =
               Pathfinder.new(
                  function(point)
                     return not collision_matrices[position_c.level]:get(point)
                  end,
                  Point.offset(chase_c.target.point, -16, -16),
                  Point.offset(chase_c.target.point, 16, 16)
               )
         end
         local pathfinder = pathfinders_by_chase_target[chase_c.target]
         pathfinder:reset()
         local path = pathfinder:find_path(position_c.point, chase_c.target.point)

         if path ~= nil and #path > 2 then
            entity_manager:update_component(entity_id, position_c, { point = path[2] })
            entity_manager:update_component(entity_id, chase_c, { time_since_last_movement = 0 })
         end

         ::continue::
      end
   end
end
