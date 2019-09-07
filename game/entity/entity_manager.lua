local yield = coroutine.yield

local component_names = require("game.entity.component_names")
local events = require("game.event.events")
local subjects = require("game.event.subjects")

local EntityManager = {}

function EntityManager:new_entity_id()
   self._entity_id = self._entity_id + 1
   return self._entity_id
end

function EntityManager:get_component(entity_id, component_name)
   return self._components[component_name][entity_id]
end

function EntityManager:has_component(entity_id, component_name)
   return self._components[component_name][entity_id] ~= nil
end

function EntityManager:add_component(entity_id, component)
   if self._components[component.name] == nil then
      local component_name_str =
         type(component.name) == "string"
            and component.name
            or string.format("<%s>", type(component.name))
      error("unknown component being added: " .. component_name_str)
   end

   self._components[component.name][entity_id] = component

   subjects.entity_manager:notify(events.component_added, { component_name = component.name, id = entity_id })
end

function EntityManager:get_unique_component(component_name)
   local unique_entity_id, unique_component
   for entity_id, component in pairs(self._components[component_name]) do
      if unique_component ~= nil then
         error("component regarded as unique was not unique; name: " .. component_name)
      end

      unique_entity_id = entity_id
      unique_component = component
   end

   if not unique_component then
      error("could not find unique component; name: " .. component_name)
   end

   return unique_entity_id, unique_component
end

function EntityManager:update_component(entity_id, component, new_fields)
   local old_fields = {}
   for key, value in pairs(new_fields) do
      old_fields[key] = self._components[component.name][entity_id][key]
      self._components[component.name][entity_id][key] = value
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
   local iterated_names = {...}

   if arg_count == 1 then
      return pairs(self._components[iterated_names[1]])
   end

   local function iter()
      if arg_count == 2 then
         local first_components = self._components[iterated_names[1]]
         local second_components = self._components[iterated_names[2]]

         for id = 1, self._entity_id do
            if first_components[id] ~= nil and second_components[id] ~= nil then
               yield(id, first_components[id], second_components[id])
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
      local components = {}
      for name in pairs(component_names) do
         components[name] = {}
      end

      local instance = instantiate(EntityManager, {
         _components = components,
         _entity_id = 0,
      })
      return instance
   end
}
