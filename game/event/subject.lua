local Set = require("game.data_structures.set")
local events = require("game.event.events")

local Subject = {}

local ignored_events = Set.new({
   events.component_added,
   events.component_updated,
})

function Subject:add_observer(observer)
   self._observers[observer] = observer
end

function Subject:remove_observer(observer)
   self._observers[observer] = nil
end

function Subject:notify(event, data)
   if not ignored_events:contains(event) then
      log.debug("event: " .. event, data)
   end

   for _, observer in pairs(self._observers) do
      observer(event, data)
   end
end

return {
   new = function()
      local instance = instantiate(Subject, {
         _observers = {},
      })
      return instance
   end,
}
