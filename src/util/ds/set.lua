local Set = prototype(function(self, values)
   assertx.is_table_or_nil(values)

   self._contents = {}
   self._size = 0

   if values ~= nil then
      for _, elem in ipairs(values) do
         self:add(elem)
      end
   end
end)

function Set:add(elem)
   if self:contains(elem) then
      return
   end

   self._contents[elem] = elem
   self._size = self._size + 1
end

function Set:contains(elem)
   return self._contents[elem] == elem
end

function Set:remove(elem)
   if not self:contains(elem) then
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

return Set
