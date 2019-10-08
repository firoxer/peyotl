local Set = {}

function Set:add(elem)
   if self:contains(elem) then
      return
   end

   self._contents[elem] = elem
   self._size = self._size + 1
end

function Set:contains(elem)
   return self._contents[elem] ~= nil
end

function Set:remove(elem)
   if self._contents[elem] == nil then
      return
   end

   self._contents[elem] = nil
   self._size = self._size - 1
end

function Set:is_empty()
   return self._size == 0
end

function Set:pairs()
   return pairs(self._contents)
end

return {
   new = function(values)
      assert(type(values) == "table" or values == nil, "initial values must be a table or omitted altogether")

      local instance = instantiate(Set, {
         _contents = {},
         _size = 0,
      })

      if values ~= nil then
         for _, elem in ipairs(values) do
            instance:add(elem)
         end
      end

      return instance
   end
}
