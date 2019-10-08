local component_names = require("game.entity.component_names")
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

return function(levels_config, entity_manager, player_input)
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

   entity_manager.subject:subscribe(function(event, data)
      if event == events.component_added and data.component_name == component_names.collision then
         local position_c = entity_manager:get_component(data.entity_id, component_names.position)
         collision_matrices[position_c.level]:set(position_c.point, true)
      end
   end)

   entity_manager.subject:subscribe(function(event, data)
      if event == events.component_to_be_updated and data.component_name == component_names.position then
         if entity_manager:has_component(data.entity_id, component_names.collision) then
            local position_c = entity_manager:get_component(data.entity_id, component_names.position)
            collision_matrices[position_c.level]:set(position_c.point, false)
            collision_matrices[position_c.level]:set(data.updated_fields.point, true)
         end
      end
   end)

   local pending_events = ds.Queue.new()
   player_input.subject:subscribe(function(event)
      pending_events:enqueue(event)
   end)

   return function()
      while not pending_events:is_empty() do
         local event = pending_events:dequeue()
         for entity_id, _, position_c in entity_manager:iterate(component_names.input, component_names.position) do
            local point_diff_x, point_diff_y = offset_by_event(event)

            if not point_diff_x or not point_diff_y then
               -- Event matched no movement
               goto continue
            end

            local collision_matrix = collision_matrices[position_c.level]

            -- Orthogonal movement
            if point_diff_x == 0 or point_diff_y == 0 then
               if collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
                  entity_manager:update_component(entity_id, position_c, {
                     point = offset(position_c.point, point_diff_x, point_diff_y)
                  })
               end

               goto continue
            end

            -- Diagonal movement, allowing sticking to a wall when one axis collides
            if collision_matrix:get(offset(position_c.point, point_diff_x, point_diff_y)) ~= true then
               entity_manager:update_component(entity_id, position_c, {
                  point = offset(position_c.point, point_diff_x, point_diff_y)
               })
            elseif collision_matrix:get(offset(position_c.point, point_diff_x, 0)) ~= true then
               entity_manager:update_component(entity_id, position_c, {
                  point = offset(position_c.point, point_diff_x, 0)
               })
            elseif collision_matrix:get(offset(position_c.point, 0, point_diff_y)) ~= true then
               entity_manager:update_component(entity_id, position_c, {
                  point = offset(position_c.point, 0, point_diff_y)
               })
            end

            ::continue::
         end
      end
   end
end
