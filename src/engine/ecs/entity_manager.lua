local EventSubject = require("src.engine.event.event_subject")

local events = tablex.identity({
   "entity_to_be_removed",
})

local EntityManager = prototype(function(self, component_names)
   self.event_subject = EventSubject(events)

   self._components = nil
   self._entity_id = 0

   self:flush(component_names)
end)

function EntityManager:new_entity_id()
   self._entity_id = self._entity_id + 1
   return self._entity_id
end

function EntityManager:_compose_entity(entity_id)
   local entity_components = {}

   for component_name, component in pairs(self._components) do
      if component[entity_id] then
         entity_components[component_name] = component[entity_id]
      end
   end

   return entity_components
end

function EntityManager:remove_entity(entity_id)
   assertx.is_number(entity_id)

   self.event_subject:notify(
      events.entity_to_be_removed,
      { entity = self:_compose_entity(entity_id) }
   )

   for _, component in pairs(self._components) do
      component[entity_id] = nil
   end
end

function EntityManager:get_component(entity_id, component_name)
   assertx.is_number(entity_id)
   assertx.is_string(component_name)

   return self._components[component_name][entity_id]
end

function EntityManager:has_component(entity_id, component_name)
   assertx.is_number(entity_id)
   assertx.is_string(component_name)

   return self._components[component_name][entity_id] ~= nil
end

function EntityManager:add_component(entity_id, component)
   assertx.is_number(entity_id)
   assertx.is_table(component)

   if self._components[component.name] == nil then
      local component_name_str =
         type(component.name) == "string" and component.name or string.format("<%s>", type(component.name))
      error("unknown component being added: " .. component_name_str)
   end

   self._components[component.name][entity_id] = component
end

function EntityManager:get_unique_component(component_name)
   assertx.is_string(component_name)

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

function EntityManager:update_component(entity_id, component_name, fields)
   assertx.is_number(entity_id)
   assertx.is_string(component_name)
   assertx.is_table(fields)

   for key, value in pairs(fields) do
      self._components[component_name][entity_id][key] = value
   end
end

function EntityManager:remove_component(entity_id, component_name)
   assertx.is_number(entity_id)
   assertx.is_string(component_name)

   self._components[component_name][entity_id] = nil
end

function EntityManager:iterate(...)
   local arg_count = select("#", ...)
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
               coroutine.yield(id, first_components[id], second_components[id])
            end
         end
      else
         error("not implemented")
      end
   end

   return coroutine.wrap(
      function()
         iter()
      end
   )
end

function EntityManager:flush(component_names)
   self._components = {}

   for _, name in ipairs(component_names) do
      self._components[name] = {}
   end
end

return EntityManager
