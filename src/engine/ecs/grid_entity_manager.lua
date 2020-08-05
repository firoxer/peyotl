--- WIP

local EntityManager = require("src.engine.ecs.entity_manager")

local GridEntityManager = {}

function GridEntityManager:initialize()
   self._matrices = {}
end

function EntityManager:add_component(entity_id, component)
   if component.name == "position" then
      return
   end

   if self._components.position[entity_id] == nil then
      log.error("damn")
      return
   end

   if self._matrices[component.name] == nil then
      self._matrices[component.name] = ds.Matrix()
   end

   local point = self._components.position[entity_id].point
   self._matrices[component.name]:set(point, component) -- TODO: What about multiple components in the same point
end

function EntityManager:remove_entity(entity_id)
   local point = self._components.position[entity_id].point

   for _, matrix in pairs(self._matrices) do
      matrix:remove(point)
   end
end

function EntityManager:remove_component(entity_id, component_name)
   local point = self._components.position[entity_id].point
   self._matrices[component_name]:remove(point)
end

function GridEntityManager:get_matrix_for(component_name)
   return self._matrices[component_name]
end

local prototype = prototypify(GridEntityManager, EntityManager)
return prototype
