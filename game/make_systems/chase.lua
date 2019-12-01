local BreadthFirst = require("game.pathfinding.breadth_first")

local chebyshev_distance = ds.Point.chebyshev_distance

local function create_collision_matrices(levels_config)
   local collision_matrices = {}
   for level_name, level_config in pairs(levels_config) do
      local matrix = ds.Matrix.new()
      for y = 1, level_config.height do
         for x = 1, level_config.width do
            matrix:set(ds.Point.new(x, y), false)
         end
      end
      collision_matrices[level_name] = matrix
   end

   return collision_matrices
end

return function(levels_config, entity_manager)
   local collision_matrices = create_collision_matrices(levels_config)
   local pathfinders_by_level_and_chase_target_id = {}

   for level_name in pairs(levels_config) do
      pathfinders_by_level_and_chase_target_id[level_name] = {}
   end

   entity_manager.subject:subscribe_to_any_change_of(
      { "position", "collision" },
      function(event_data, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            collision_matrices[position_c.level]:set(position_c.point, false)
            collision_matrices[position_c.level]:set(event_data.updated_fields.point, true)
         else
            collision_matrices[position_c.level]:set(position_c.point, true)
         end

         for _, pathfinder in pairs(pathfinders_by_level_and_chase_target_id[position_c.level]) do
            pathfinder:recalculate_at(position_c.point)

            if event_data.updated_fields and event_data.updated_fields.point then
               pathfinder:recalculate_at(event_data.updated_fields.point)
            end
         end
      end
   )

   entity_manager.subject:subscribe_to_any_change_of(
      { "position", "input" },
      function(event_data, position_c)
         if not event_data.updated_fields
               or (not event_data.updated_fields.point and not event_data.updated_fields.level) then
            return
         end

         local pathfinder = pathfinders_by_level_and_chase_target_id[position_c.level][event_data.entity_id]

         if not pathfinder then
            return
         end

         local chase_target_level = event_data.updated_fields.level or position_c.level
         if pathfinder.level ~= chase_target_level then
            return
         end

         local chase_target_point = event_data.updated_fields.point or position_c.point

         pathfinder:change_destination_to(chase_target_point)
      end
   )

   return function()
      local current_time = love.timer.getTime()
      for entity_id, chase_c, position_c in entity_manager:iterate("chase", "position") do
         if current_time - chase_c.time_at_last_movement < 1 then
            goto continue
         end

         local chased_position_c =
            entity_manager:get_component(chase_c.target_id, "position")

         if position_c.level ~= chased_position_c.level then
            goto continue
         end

         local aggro_range = levels_config[position_c.level].monsters.aggro_range
         if aggro_range then
            if chebyshev_distance(position_c.point, chased_position_c.point) > aggro_range then
               goto continue
            end
         end

         local pathfinder = pathfinders_by_level_and_chase_target_id[position_c.level][chase_c.target_id]
         if not pathfinder then
            pathfinder = BreadthFirst.new(collision_matrices[position_c.level], position_c.level, aggro_range)
            pathfinders_by_level_and_chase_target_id[position_c.level][chase_c.target_id] = pathfinder
            pathfinder:change_destination_to(chased_position_c.point)
         end

         local next_point = pathfinder:find_next_step(position_c.point)
         if next_point ~= nil and next_point ~= chased_position_c.point then
            entity_manager:update_component(entity_id, position_c, { point = next_point })
            entity_manager:update_component(entity_id, chase_c, { time_at_last_movement = current_time })
         end

         ::continue::
      end
   end
end
