local events = require("game.event.events")

local offset = ds.Point.offset

local function offset_by_event(event)
   if event == events.move_n then
      return 0, -1
   elseif event == events.move_ne then
      return 1, -1
   elseif event == events.move_e then
      return 1, 0
   elseif event == events.move_se then
      return 1, 1
   elseif event == events.move_s then
      return 0, 1
   elseif event == events.move_sw then
      return -1, 1
   elseif event == events.move_w then
      return -1, 0
   elseif event == events.move_nw then
      return -1, -1
   end
end

local function track_collidable_positions_in_matrix(level_config, em)
   local matrix = ds.Matrix()

   for y = 1, level_config.height do
      for x = 1, level_config.width do
         matrix:set(ds.Point.get(x, y), false)
      end
   end

   em.subject:subscribe(events.component_added, function(event_data)
      if event_data.component_name == "collision" then
         local position_c = em:get_component(event_data.entity_id, "position")
         matrix:set(position_c.point, true)
      end
   end)

   em.subject:subscribe(events.component_to_be_updated, function(event_data)
      if event_data.component_name == "position" and
            em:has_component(event_data.entity_id, "collision") then
         local position_c = em:get_component(event_data.entity_id, "position")
         matrix:set(position_c.point, false)
         matrix:set(event_data.updated_fields.point, true)
      end
   end)

   return matrix
end

local within_bounds = function(level_config, point)
   return
      point.x >= 1
      and point.y >= 1
      and point.x <= level_config.width
      and point.y <= level_config.height
end

return function(level_config, em, player_input)
   assertx.is_table(level_config)
   assertx.is_instance_of("entity.EntityManager", em)
   assertx.is_instance_of("event.Subject", player_input.subject)

   local collision_matrix = track_collidable_positions_in_matrix(level_config, em)

   player_input.subject:subscribe_all(function(event)
      for _, input_c in em:iterate("input") do
         input_c.pending_events:enqueue(event)
      end
   end)

   return function()
      for entity_id, input_c, position_c in em:iterate("input", "position") do
         while not input_c.pending_events:is_empty() do
            local event = input_c.pending_events:dequeue()

            local point_diff_x, point_diff_y = offset_by_event(event)

            if not point_diff_x or not point_diff_y then
               -- Event matched no movement
               goto continue
            end

            local new_point = nil

            -- Orthogonal movement
            if point_diff_x == 0 or point_diff_y == 0 then
               if collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
                  new_point = offset(position_c.point, point_diff_x, point_diff_y)
               end
            -- Diagonal movement, allowing sticking to a wall when one axis collides
            elseif collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
               new_point = offset(position_c.point, point_diff_x, point_diff_y)
            elseif collision_matrix:get(offset(position_c.point, point_diff_x, 0)) ~= true then
               new_point = offset(position_c.point, point_diff_x, 0)
            elseif collision_matrix:get(offset(position_c.point, 0, point_diff_y)) ~= true then
               new_point = offset(position_c.point, 0, point_diff_y)
            end

            if new_point == nil or not within_bounds(level_config, new_point) then
               goto continue
            end

            em:update_component(entity_id, "position", { point = new_point })

            ::continue::
         end
      end
   end
end
