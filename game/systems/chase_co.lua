local BreadthFirst = require("game.pathfinding.breadth_first")
local Matrix = require("game.data_structures.matrix")
local Point = require("game.data_structures.point")
local component_names = require("game.entity.component_names")

local function create_collision_matrices(levels_config)
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

   return collision_matrices
end

return function(levels_config, entity_manager)
   local collision_matrices = create_collision_matrices(levels_config)
   local pathfinders_by_chase_target = {}

   entity_manager.subject:subscribe_to_any_change_of(
      { component_names.position, component_names.collision },
      function(event_data, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            collision_matrices[position_c.level]:set(position_c.point, false)
            collision_matrices[position_c.level]:set(event_data.updated_fields.point, true)
         else
            collision_matrices[position_c.level]:set(position_c.point, true)
         end

         for _, pathfinder in pairs(pathfinders_by_chase_target) do
            pathfinder:update_point(position_c.point)

            if event_data.updated_fields and event_data.updated_fields.point then
               pathfinder:update_point(event_data.updated_fields.point)
            end
         end
      end
   )

   entity_manager.subject:subscribe_to_any_change_of(
      { component_names.position, component_names.input },
      function()
         for chase_target, pathfinder in pairs(pathfinders_by_chase_target) do
            pathfinder:update_all(chase_target.point)
         end
      end
   )

   return coroutine.wrap(function()
      while true do
         local current_time = love.timer.getTime()
         for entity_id, chase_c, position_c
               in entity_manager:iterate(component_names.chase, component_names.position) do
            if current_time - chase_c.time_at_last_movement < 1 then
               goto continue
            end

            if position_c.level ~= chase_c.target.level then
               goto continue
            end

            local aggro_range = levels_config[position_c.level].monsters.aggro_range
            if Point.chebyshev_distance(position_c.point, chase_c.target.point) > aggro_range then
               goto continue
            end

            local pathfinder = pathfinders_by_chase_target[chase_c.target]
            if not pathfinder then
               pathfinder = BreadthFirst.new(collision_matrices[position_c.level], aggro_range)
               pathfinders_by_chase_target[chase_c.target] = pathfinder
               pathfinder:update_all(chase_c.target.point)
            end
            local next_point = pathfinder:find_next_step(position_c.point)
            if next_point ~= nil and next_point ~= chase_c.target.point then
               entity_manager:update_component(entity_id, position_c, { point = next_point })
               entity_manager:update_component(entity_id, chase_c, { time_at_last_movement = current_time })
            end

            ::continue::
         end

         coroutine.yield()
      end
   end)
end
