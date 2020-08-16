local EventSubject = require("src.engine.event.event_subject")

do
   local s = EventSubject(tablex.identity({ "test_event" }))

   local event_fired = false
   s:subscribe('test_event', function(event)
      event_fired = true
      assert(event.data == 'test_event_data')
   end)

   s:notify('test_event', { data = 'test_event_data' })

   assert(event_fired)
end

do
   local s = EventSubject(tablex.identity({ "test_event_a", "test_event_b" }))

   local event_fired = false
   s:subscribe('test_event_a', function()
      event_fired = true
   end)

   s:notify('test_event_b', nil)

   assert(not event_fired)
end

do
   local s = EventSubject(tablex.identity({ "test_event" }))

   local event_fired = false
   s:subscribe_all(function()
      event_fired = true
   end)

   s:notify('test_event', nil)

   assert(event_fired)
end
