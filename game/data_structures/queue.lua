-- From http://www.lua.org/pil/11.4.html

local Queue = {}

function Queue:enqueue(e)
   local last = self._last + 1
   self._last = last
   self._contents[last] = e
end

function Queue:dequeue()
   if self:is_empty() then
      error("trying to dequeue an empty queue")
   end

   local first = self._first
   local e = self._contents[first]
   self._contents[first] = nil -- For GC
   self._first = first + 1

   return e
end

function Queue:peek()
   return self._contents[self._first]
end

function Queue:is_empty()
   return self._first > self._last
end

return {
   new = function()
      local instance = instantiate(Queue, {
         _contents = {},
         _first = 0,
         _last = -1,
      })
      return instance
   end
}
