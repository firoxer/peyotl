local BreadthFirst = require("game.pathfinding.breadth_first")

local chebyshev_distance = ds.Point.chebyshev_distance

local function track_collidable_positions_as_matrices_by_level(levels_config, entity_manager)
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

   entity_manager.subject:subscribe_to_any_change_of(
      { "position", "collision" },
      function(event_data, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            collision_matrices[position_c.level]:set(position_c.point, false)
            collision_matrices[position_c.level]:set(event_data.updated_fields.point, true)
         else
            collision_matrices[position_c.level]:set(position_c.point, true)
         end
      end
   )

   return collision_matrices
end

local function track_chaseables_by_level_as_pathfinders(levels_config, entity_manager, collision_matrices)
   local pathfinders_by_level_and_chase_target_id = {}

   entity_manager.subject:subscribe_to_any_change_of(
      { "chaseable", "position" },
      function(event_data, _, position_c)
         local level = position_c.level
         local point = position_c.point
         if event_data.updated_fields then
            if event_data.updated_fields.point then
               point = event_data.updated_fields.point
            elseif event_data.updated_fields.level then
               level = event_data.updated_fields.level
            end
         end

         if not pathfinders_by_level_and_chase_target_id[level] then
            pathfinders_by_level_and_chase_target_id[level] = {}
         end

         if not pathfinders_by_level_and_chase_target_id[level][event_data.entity_id] then
            pathfinders_by_level_and_chase_target_id[level][event_data.entity_id] =
               BreadthFirst.new(
                  collision_matrices[level],
                  level,
                  levels_config[level].monsters.aggro_range
               )
         end

         local pathfinder =
            pathfinders_by_level_and_chase_target_id[level][event_data.entity_id]

         pathfinder:change_destination_to(point)
      end
   )

   entity_manager.subject:subscribe_to_any_change_of(
      { "position", "collision" },
      function(event_data, position_c)
         local pathfinders = pathfinders_by_level_and_chase_target_id[position_c.level]
         if pathfinders then
            for _, pathfinder in pairs(pathfinders) do
               pathfinder:recalculate_at(position_c.point)

               if event_data.updated_fields and event_data.updated_fields.point then
                  pathfinder:recalculate_at(event_data.updated_fields.point)
               end
            end
         end
      end
   )

   return pathfinders_by_level_and_chase_target_id
end

local function too_far(pos_a, pos_b, range)
   return
      pos_a.level ~= pos_b.level
      or (range ~= math.huge and chebyshev_distance(pos_a.point, pos_b.point) > range)
end

return function(levels_config, entity_manager)
   local collision_matrices =
      track_collidable_positions_as_matrices_by_level(levels_config, entity_manager)
   local pathfinders_by_level_and_chase_target_id =
      track_chaseables_by_level_as_pathfinders(levels_config, entity_manager, collision_matrices)

   return function()
      local current_time = love.timer.getTime()
      for entity_id, chase_c, position_c in entity_manager:iterate("chase", "position") do
         local too_soon_to_move = current_time - chase_c.time_at_last_movement < chase_c.time_between_movements
         if too_soon_to_move then
            goto continue
         end

         local chased_position_c = entity_manager:get_component(chase_c.target_id, "position")

         if too_far(position_c, chased_position_c, chase_c.aggro_range) then
            goto continue
         end

         local pathfinder = pathfinders_by_level_and_chase_target_id[position_c.level][chase_c.target_id]
         if not pathfinder then
            log.error("no pathfinder for chase target", chase_c)
            goto continue
         end

         local next_point = pathfinder:find_next_step(position_c.point)
         if next_point ~= nil and next_point ~= chased_position_c.point then
            entity_manager:update_component(entity_id, "position", { point = next_point })
            entity_manager:update_component(entity_id, "chase", { time_at_last_movement = current_time })
         end

         ::continue::
      end
   end
end
