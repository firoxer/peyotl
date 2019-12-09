local events = require("game.event.events")

local Subject = {}

local log_events = false

-- These are events that are just too much
local totally_ignored_events = ds.Set.new({
   events.component_added,
   events.component_to_be_updated,
})

function Subject:subscribe_all(observer)
   assertx.is_function(observer)

   self._observers[observer] = observer
end

function Subject:subscribe(event, observer)
   assertx.is_string(event)
   assertx.is_function(observer)

   self._observers[observer] = function(ev, ...)
      if event == ev then
         observer(...)
      end
   end
end

function Subject:subscribe_many(observers)
   assertx.is_table(observers)

   for event, observer in pairs(observers) do
      self:subscribe(event, observer)
   end
end

function Subject:unsubscribe(observer)
   self._observers[observer] = nil
end

function Subject:notify(event, event_data)
   if log_events and not totally_ignored_events:contains(event) then
      log.debug("event: " .. event, event_data)
   end

   for _, observer in pairs(self._observers) do
      observer(event, event_data)
   end
end

local create_object = prototypify(Subject)
return {
   new = function()
      return create_object({
         _observers = {},
      })
   end,

   enable_event_logging = function()
      log_events = true
   end,
}
