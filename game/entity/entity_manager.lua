local components = require("game.entity.components")
local events = require("game.event.events")
local subjects = require("game.event.subjects")

local EntityManager = {}

function EntityManager:new_entity_id()
   self._entity_id = self._entity_id + 1
   return self._entity_id
end

function EntityManager:get_component(entity_id, component_name)
   return self._entities[component_name][entity_id]
end

function EntityManager:has_component(entity_id, component_name)
   return self._entities[component_name][entity_id] ~= nil
end

function EntityManager:add_component(entity_id, component)
   if self._entities[component.name] == nil then
      local component_name_str =
         type(component.name) == "string"
            and component.name
            or string.format("<%s>", type(component.name))
      error("unknown component being added: " .. component_name_str)
   end

   self._entities[component.name][entity_id] = component

   subjects.entity_manager:notify(events.component_added, { component_name = component.name, id = entity_id })
end

function EntityManager:update_component(entity_id, component, new_fields)
   local old_fields = {}
   for key, value in pairs(new_fields) do
      old_fields[key] = self._entities[component.name][entity_id][key]
      self._entities[component.name][entity_id][key] = value
   end

   subjects.entity_manager:notify(events.component_updated, {
      component_name = component.name,
      id = entity_id,
      old_fields = old_fields,
      new_fields = new_fields,
   })
end

function EntityManager:iterate(...)
   local arg_count = select('#', ...)
   local component_names = {...}
   local function iter()
      if arg_count == 1 then
         for id, c in pairs(self._entities[component_names[1]]) do
            coroutine.yield(id, c)
         end
      elseif arg_count == 2 then
         local first_components = self._entities[component_names[1]]
         local second_components = self._entities[component_names[2]]

         for id = 1, self._entity_id do
            if first_components[id] ~= nil and second_components[id] ~= nil then
               coroutine.yield(id, first_components[id], second_components[id])
            end
         end
      else
         error("not implemented")
      end
   end

   return coroutine.wrap(function()
      iter()
   end)
end

return {
   new = function()
      local entities = {}
      for name in pairs(components) do
         entities[name] = {}
      end

      local instance = instantiate(EntityManager, {
         _entities = entities,
         _entity_id = 0,
      })
      return instance
   end
}
