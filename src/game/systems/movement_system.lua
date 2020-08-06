local MovementSystem = prototype(function(self, level_config, em, player_input)
   self._level_config = level_config
   self._entity_manager = em
   self._player_input = player_input

   self:_track_collidable_positions_in_matrix()

   player_input.event_subject:subscribe_all(function(event)
      for _, input_c in em:iterate("input") do
         input_c.pending_events:enqueue(event)
      end
   end)
end)

function MovementSystem:_track_collidable_positions_in_matrix()
   local em = self._entity_manager

   local matrix = ds.Matrix()

   for y = 1, self._level_config.height do
      for x = 1, self._level_config.width do
         matrix:set(ds.Point.get(x, y), false)
      end
   end

   em.event_subject:subscribe(em.event_subject.events.component_added, function(event_data)
      if event_data.component_name == "collision" then
         local position_c = em:get_component(event_data.entity_id, "position")
         matrix:set(position_c.point, true)
      end
   end)

   em.event_subject:subscribe(em.event_subject.events.component_to_be_updated, function(event_data)
      if event_data.component_name == "position" and
            em:has_component(event_data.entity_id, "collision") then
         local position_c = em:get_component(event_data.entity_id, "position")
         matrix:set(position_c.point, false)
         matrix:set(event_data.updated_fields.point, true)
      end
   end)

   self._collision_matrix = matrix
end

function MovementSystem:_within_bounds(point)
   return
      point.x >= 1
      and point.y >= 1
      and point.x <= self._level_config.width
      and point.y <= self._level_config.height
end

function MovementSystem:_offset_by_event(event)
   local input_events = self._player_input.event_subject.events

   if event == input_events.move_n then
      return 0, -1
   elseif event == input_events.move_ne then
      return 1, -1
   elseif event == input_events.move_e then
      return 1, 0
   elseif event == input_events.move_se then
      return 1, 1
   elseif event == input_events.move_s then
      return 0, 1
   elseif event == input_events.move_sw then
      return -1, 1
   elseif event == input_events.move_w then
      return -1, 0
   elseif event == input_events.move_nw then
      return -1, -1
   end
end

function MovementSystem:run()
   for entity_id, input_c, position_c in self._entity_manager:iterate("input", "position") do
      while not input_c.pending_events:is_empty() do
         local event = input_c.pending_events:dequeue()

         local point_diff_x, point_diff_y = self:_offset_by_event(event)

         if not point_diff_x or not point_diff_y then
            -- Event matched no movement
            goto continue
         end

         local new_point = nil

         local offset = ds.Point.offset
         -- Orthogonal movement
         if point_diff_x == 0 or point_diff_y == 0 then
            if self._collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
               new_point = offset(position_c.point, point_diff_x, point_diff_y)
            end
         -- Diagonal movement, allowing sticking to a wall when one axis collides
         elseif self._collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
            new_point = offset(position_c.point, point_diff_x, point_diff_y)
         elseif self._collision_matrix:get(offset(position_c.point, point_diff_x, 0)) ~= true then
            new_point = offset(position_c.point, point_diff_x, 0)
         elseif self._collision_matrix:get(offset(position_c.point, 0, point_diff_y)) ~= true then
            new_point = offset(position_c.point, 0, point_diff_y)
         end

         if new_point == nil or not self:_within_bounds(new_point) then
            goto continue
         end

         self._entity_manager:update_component(entity_id, "position", { point = new_point })

         ::continue::
      end
   end
end

return MovementSystem