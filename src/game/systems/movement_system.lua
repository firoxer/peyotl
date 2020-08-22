local System = require("src.engine.ecs.system")

local MovementSystem = prototype(System, function(self, world_config, entity_manager, player_input)
   self._world_config = world_config
   self._entity_manager = entity_manager
   self._player_input = player_input

   self._collision_matrix = ds.Matrix()

   player_input.event_subject:subscribe_all(function(event)
      for _, input_c in entity_manager:iterate("input") do
         input_c.pending_events:enqueue(event)
      end
   end)
end)

function MovementSystem:_update_collision_matrix()
   local matrix = self._collision_matrix

   for y = 1, self._world_config.height do
      for x = 1, self._world_config.width do
         matrix:set(ds.Point.get(x, y), false)
      end
   end

   for _, position_c in self._entity_manager:iterate("position", "collision") do
      matrix:set(position_c.point, true)
   end
end

function MovementSystem:_within_bounds(point)
   return
      point.x >= 1
      and point.y >= 1
      and point.x <= self._world_config.width
      and point.y <= self._world_config.height
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
         -- TODO: Check if this can be run less often
         self:_update_collision_matrix()

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