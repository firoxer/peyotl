local Set = {}

function Set:add(elem)
   if self:contains(elem) then
      return
   end

   self._contents[elem] = elem
end

function Set:contains(elem)
   return self._contents[elem] ~= nil
end

function Set:remove(elem)
   self._contents[elem] = nil
end

function Set:size()
   local size = 0
   for _ in pairs(self._contents) do
      size = size + 1
   end

   return size
end

function Set:pairs()
   return pairs(self._contents)
end

return {
   new = function(values)
      assert(type(values) == "table" or values == nil, "initial values must be a table or omitted altogether")

      local instance = instantiate(Set, {
         _contents = {}
      })

      if values ~= nil then
         for _, elem in ipairs(values) do
            instance:add(elem)
         end
      end

      return instance
   end
}
