-- Priority queue implemented using a binary heap
-- From https://gist.github.com/LukeMS/89dc587abd786f92d60886f4977b1953

local PriorityQueue = {}

function PriorityQueue:enqueue(elem, priority)
   self._elem_heap[self._size + 1] = elem
   self._priority_heap[self._size + 1] = priority
   self._size = self._size + 1
   self:_swim()
end

function PriorityQueue:dequeue()
   if self:is_empty() then
      error("trying to dequeue an empty queue")
   end

   local elem_heap = self._elem_heap
   local priority_heap = self._priority_heap
   local elem = elem_heap[1]
   elem_heap[1] = elem_heap[self._size]
   priority_heap[1] = priority_heap[self._size]
   elem_heap[self._size] = nil
   priority_heap[self._size] = nil
   self._size = self._size - 1
   self:_sink()
   return elem
end

function PriorityQueue:is_empty()
   return self._size == 0
end

function PriorityQueue:_swim()
   local elem_heap = self._elem_heap
   local priority_heap = self._priority_heap
   local i = self._size

   while math.floor(i / 2) > 0 do
      local half = math.floor(i / 2)
      if priority_heap[i] < priority_heap[half] then
         priority_heap[i], priority_heap[half] = priority_heap[half], priority_heap[i]
         elem_heap[i], elem_heap[half] = elem_heap[half], elem_heap[i]
      end
      i = half
   end
end

function PriorityQueue:_sink()
   local elem_heap = self._elem_heap
   local priority_heap = self._priority_heap
   local i = 1

   while i * 2 <= self._size do
      local mc = self:_min_child(i)
      if priority_heap[i] > priority_heap[mc] then
         priority_heap[i], priority_heap[mc] = priority_heap[mc], priority_heap[i]
         elem_heap[i], elem_heap[mc] = elem_heap[mc], elem_heap[i]
      end
      i = mc
   end
end

function PriorityQueue:_min_child(i)
   if (i * 2) + 1 > self._size then
      return i * 2
   elseif self._priority_heap[i * 2] < self._priority_heap[(i * 2) + 1] then
      return i * 2
   else
      return (i * 2) + 1
   end
end

local create_object = prototypify(PriorityQueue)
return {
   new = function()
      return create_object({
         _elem_heap = {},
         _priority_heap = {},
         _size = 0,
      })
   end
}
