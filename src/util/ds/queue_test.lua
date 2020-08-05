do
   local q = ds.Queue()
   q:enqueue(1)
   q:enqueue(2)
   q:enqueue(3)
   assert(q:dequeue() == 1)
   assert(q:dequeue() == 2)
   assert(q:dequeue() == 3)
end

do
   local q = ds.Queue()
   q:enqueue(1)
   assert(q:dequeue() == 1)
   q:enqueue(2)
   assert(q:dequeue() == 2)
   q:enqueue(3)
   assert(q:dequeue() == 3)
end

do
   local q = ds.Queue()
   local _, err = pcall(function() q:dequeue() end)
   assert(err ~= nil)
end

do
   local q = ds.Queue()
   assert(q:is_empty() == true)
   q:enqueue("not important")
   assert(q:is_empty() == false)
   assert(q:dequeue())
   assert(q:is_empty() == true)
end
