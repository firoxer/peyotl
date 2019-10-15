-- From http://www.lua.org/pil/11.4.html

local Queue = {}

function Queue:enqueue(e)
   local last_index = self._last_index + 1
   self._last_index = last_index
   self._contents[last_index] = e
end

function Queue:dequeue()
   if self:is_empty() then
      error("trying to dequeue an empty queue")
   end

   local first_index = self._first_index
   local element = self._contents[first_index]
   self._contents[first_index] = nil -- For GC
   self._first_index = first_index + 1

   return element
end

function Queue:peek()
   return self._contents[self._first_index]
end

function Queue:is_empty()
   return self._first_index > self._last_index
end

local create_object = prototypify(Queue)
return {
   new = function()
      return create_object({
         _contents = {},
         _first_index = 0,
         _last_index = -1,
      })
   end
}
