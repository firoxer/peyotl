local events = require("game.event.events")

local Subject = {}

local log_events = false

-- These are events that are just too much
local totally_ignored_events = ds.Set({
   events.component_added,
   events.component_to_be_updated,
})

function Subject:initialize()
   self._observers = {}
end

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

function Subject:unsubscribe(observer)
   assertx.is_function(observer)

   self._observers[observer] = nil
end

function Subject:notify(event, event_data)
   assertx.is_string(event)
   assertx.is_table_or_nil(event_data)

   if log_events and not totally_ignored_events:contains(event) then
      log.debug("event: " .. event, event_data)
   end

   for _, observer in pairs(self._observers) do
      observer(event, event_data)
   end
end

function Subject:enable_event_logging()
   log_events = true
end

local prototype = prototypify(Subject)
return prototype
