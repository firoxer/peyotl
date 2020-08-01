local BreadthFirst = require("game.pathfinding.breadth_first")

local chebyshev_distance = ds.Point.chebyshev_distance

local function too_far(pos_a, pos_b, range)
   return range ~= math.huge and chebyshev_distance(pos_a.point, pos_b.point) > range
end

return function(level_config, em)
   local collision_matrix = ds.Matrix()
   local pathfinders = {}

   local update_collision_matrix = function()
      for y = 1, level_config.height do
         for x = 1, level_config.width do
            collision_matrix:set(ds.Point.get(x, y), false)
         end
      end

      for _, position_c in em:iterate("position", "collision") do
         collision_matrix:set(position_c.point, true)
      end
   end

   local update_pathfinders = function()
      for entity_id, _, position_c in em:iterate("chaseable", "position") do
         local pathfinder = BreadthFirst(collision_matrix, level_config.monsters.aggro_range)
         pathfinder:change_destination_to(position_c.point)
         pathfinders[entity_id] = pathfinder
      end
   end

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

         update_collision_matrix()
         update_pathfinders()

         local pathfinder = pathfinders[chase_c.target_id]
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
