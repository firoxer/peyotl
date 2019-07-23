local CircularBuffer = {}

function CircularBuffer:read()
   self._read_index = self._read_index + 1

   if self._read_index > self.size then
      self._read_index = 1
   end

   return self._contents[self._read_index]
end

function CircularBuffer:write(elem)
   self._write_index = self._write_index + 1

   if self._write_index > self.size then
      self._write_index = 1
   end

   self._contents[self._write_index] = elem
end

function CircularBuffer:ipairs()
   return ipairs(self._contents)
end

return {
   new = function(size)
      assert(type(size) == "number")
      assert(size >= 1, "buffer size must be one or more")

      local instance = instantiate(CircularBuffer, {
         size = size,

         _contents = {},
         _read_index = 0,
         _write_index = 0,
      })
      return instance
   end
}
