local EventSubject = {}

-- Global for all subjects
local is_logging_enabled = false

function EventSubject.enable_event_logging()
   is_logging_enabled = true
end

function EventSubject:initialize(events)
   if events then
      assertx.is_table(events)
   end

   self.events = events

   self._unlogged_events = {}
   self._observers = {}
end

function EventSubject:disable_logging_for(event)
   self._unlogged_events[event] = true
end

function EventSubject:subscribe_all(observer)
   assertx.is_function(observer)

   self._observers[observer] = observer
end

function EventSubject:subscribe(event, observer)
   assertx.is_string(event)
   assertx.is_function(observer)

   self._observers[observer] = function(ev, ...)
      if event == ev then
         observer(...)
      end
   end
end

function EventSubject:unsubscribe(observer)
   assertx.is_function(observer)

   self._observers[observer] = nil
end

function EventSubject:notify(event, event_data)
   assertx.is_string(event)
   assertx.is_table_or_nil(event_data)

   if is_logging_enabled and not self._unlogged_events:contains(event) then
      log.debug("event: " .. event, event_data)
   end

   for _, observer in pairs(self._observers) do
      observer(event, event_data)
   end
end

local prototype = prototypify(EventSubject)
return prototype
