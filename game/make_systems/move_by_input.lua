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

local function track_collidable_positions_in_matrices_by_level(levels_config, entity_manager)
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

   entity_manager.subject:subscribe(events.component_added, function(event_data)
      if event_data.component_name == "collision" then
         local position_c = entity_manager:get_component(event_data.entity_id, "position")
         collision_matrices[position_c.level]:set(position_c.point, true)
      end
   end)

   entity_manager.subject:subscribe(events.component_to_be_updated, function(event_data)
      if event_data.component_name == "position" and
            entity_manager:has_component(event_data.entity_id, "collision") then
         local position_c = entity_manager:get_component(event_data.entity_id, "position")
         collision_matrices[position_c.level]:set(position_c.point, false)
         collision_matrices[position_c.level]:set(event_data.updated_fields.point, true)
      end
   end)

   return collision_matrices
end

local within_bounds = function(level_config, point)
   return
      point.x >= 1
      and point.y >= 1
      and point.x <= level_config.width
      and point.y <= level_config.height
end

return function(levels_config, entity_manager, player_input)
   assertx.is_table(levels_config)
   assertx.is_instance_of("entity.EntityManager", entity_manager)
   assertx.is_instance_of("event.Subject", player_input.subject)

   local collision_matrices = track_collidable_positions_in_matrices_by_level(levels_config, entity_manager)

   local pending_events = ds.Queue.new()
   player_input.subject:subscribe_all(tablex.bind(pending_events, "enqueue"))

   return function()
      while not pending_events:is_empty() do
         local event = pending_events:dequeue()
         for entity_id, _, position_c in entity_manager:iterate("input", "position") do
            local point_diff_x, point_diff_y = offset_by_event(event)

            if not point_diff_x or not point_diff_y then
               -- Event matched no movement
               goto continue
            end

            local new_point = nil

            local collision_matrix = collision_matrices[position_c.level]
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

            if new_point == nil or not within_bounds(levels_config[position_c.level], new_point) then
               goto continue
            end

            entity_manager:update_component(entity_id, "position", { point = new_point })

            ::continue::
         end
      end
   end
end
