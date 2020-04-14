local BreadthFirst = require("game.pathfinding.breadth_first")

local chebyshev_distance = ds.Point.chebyshev_distance

local function track_collidable_positions_as_matrix(level_config, em)
   local matrix = ds.Matrix()
   for y = 1, level_config.height do
      for x = 1, level_config.width do
         matrix:set(ds.Point.get(x, y), false)
      end
   end

   em.subject:subscribe_to_any_change_of(
      { "position", "collision" },
      function(event_data, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            matrix:set(position_c.point, false)
            matrix:set(event_data.updated_fields.point, true)
         else
            matrix:set(position_c.point, true)
         end
      end
   )

   return matrix
end

local function track_chaseables_as_pathfinders(level_config, em, collision_matrix)
   local pathfinders = {}

   em.subject:subscribe_to_any_change_of(
      { "chaseable", "position" },
      function(event_data, _, position_c)
         local point = position_c.point
         if event_data.updated_fields then
            if event_data.updated_fields.point then
               point = event_data.updated_fields.point
            end
         end

         if not pathfinders[event_data.entity_id] then
            pathfinders[event_data.entity_id] =
               BreadthFirst(collision_matrix, level_config.monsters.aggro_range)
         end

         local pathfinder =
            pathfinders[event_data.entity_id]

         pathfinder:change_destination_to(point)
      end
   )

   em.subject:subscribe_to_any_change_of(
      { "position", "collision" },
      function(event_data, position_c)
         for _, pathfinder in pairs(pathfinders) do
            pathfinder:recalculate_at(position_c.point)

            if event_data.updated_fields and event_data.updated_fields.point then
               pathfinder:recalculate_at(event_data.updated_fields.point)
            end
         end
      end
   )

   return pathfinders
end

local function too_far(pos_a, pos_b, range)
   return range ~= math.huge and chebyshev_distance(pos_a.point, pos_b.point) > range
end

return function(level_config, em)
   local collision_matrix =
      track_collidable_positions_as_matrix(level_config, em)
   local pathfinders_and_chase_target_id =
      track_chaseables_as_pathfinders(level_config, em, collision_matrix)

   return function()
      local current_time = love.timer.getTime()
      for entity_id, chase_c, position_c in em:iterate("chase", "position") do
         local too_soon_to_move = current_time - chase_c.time_at_last_movement < chase_c.time_between_movements
         if too_soon_to_move then
            goto continue
         end

         local chased_position_c = em:get_component(chase_c.target_id, "position")

         if too_far(position_c, chased_position_c, chase_c.aggro_range) then
            goto continue
         end

         local pathfinder = pathfinders_and_chase_target_id[chase_c.target_id]
         if not pathfinder then
            log.error("no pathfinder for chase target", chase_c)
            goto continue
         end

         local next_point = pathfinder:find_next_step(position_c.point)
         if next_point ~= nil and next_point ~= chased_position_c.point then
            em:update_component(entity_id, "position", { point = next_point })
            em:update_component(entity_id, "chase", { time_at_last_movement = current_time })
         end

         ::continue::
      end
   end
end
