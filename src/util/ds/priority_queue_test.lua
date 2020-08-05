do
   local q = ds.PriorityQueue()
   q:enqueue("a", 1)
   q:enqueue("b", 2)
   q:enqueue("c", 3)
   assert(q:dequeue() == "a")
   assert(q:dequeue() == "b")
   assert(q:dequeue() == "c")
end

do
   local q = ds.PriorityQueue()
   q:enqueue("a", 1)
   assert(q:dequeue() == "a")
   q:enqueue("b", 1)
   assert(q:dequeue() == "b")
   q:enqueue("c", 1)
   assert(q:dequeue() == "c")
end

do
   local q = ds.PriorityQueue()
   local _, err = pcall(function() q:dequeue() end)
   assert(err ~= nil)
end

do
   local q = ds.PriorityQueue()
   assert(q:is_empty() == true)
   q:enqueue("a", 1)
   assert(q:is_empty() == false)
   assert(q:dequeue())
   assert(q:is_empty() == true)
end

do
   local q = ds.PriorityQueue()
   q:enqueue("a", 3)
   q:enqueue("b", 2)
   q:enqueue("c", 1)
   assert(q:dequeue() == "c")
   assert(q:dequeue() == "b")
   assert(q:dequeue() == "a")
end
