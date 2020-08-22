local BreadthFirst = require("src.engine.pathfinding.breadth_first")
local System = require("src.engine.ecs.system")

local function too_far(pos_a, pos_b, range)
   if range == math.huge then
      return false
   end

   return ds.Point.chebyshev_distance(pos_a.point, pos_b.point) > range
end

local ChaseSystem = prototype(System, function(self, world_config, entity_manager)
   self._world_config = world_config
   self._entity_manager = entity_manager

   self._collision_matrix = ds.Matrix()
   self._pathfinders = {}
end)

function ChaseSystem:_update_collision_matrix()
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

function ChaseSystem:_update_pathfinders()
   for entity_id, _, position_c in self._entity_manager:iterate("chaseable", "position") do
      local pathfinder = BreadthFirst(
         self._collision_matrix,
         self._world_config.monsters.aggro_range
      )
      pathfinder:change_destination_to(position_c.point)
      self._pathfinders[entity_id] = pathfinder
   end
end

function ChaseSystem:run()
   local entity_manager = self._entity_manager

   local current_time = love.timer.getTime()
   for entity_id, chase_c, position_c in entity_manager:iterate("chase", "position") do
      local too_soon_to_move =
         current_time - chase_c.time_at_last_movement < chase_c.time_between_movements
      if too_soon_to_move then
         goto continue
      end

      local chased_position_c = entity_manager:get_component(chase_c.target_id, "position")

      if too_far(position_c, chased_position_c, chase_c.aggro_range) then
         goto continue
      end

      self:_update_collision_matrix()
      self:_update_pathfinders()

      local pathfinder = self._pathfinders[chase_c.target_id]
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

return ChaseSystem