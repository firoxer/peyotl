local CircularBuffer = {}

function CircularBuffer:read()
   -- Faster than modulo
   self._read_index = self._read_index + 1
   if self._read_index == self._write_index + 1 then
      error("trying to read an empty buffer")
   end
   if self._read_index > self.size then
      self._read_index = 1
   end

   return self._contents[self._read_index]
end

function CircularBuffer:write(elem)
   -- Faster than modulo
   self._write_index = self._write_index + 1
   if self._write_index == self._read_index then
      error("trying to write to a full buffer")
   end
   if self._write_index > self.size then
      self._write_index = 1
   end

   self._contents[self._write_index] = elem
end

function CircularBuffer:ipairs()
   return ipairs(self._contents)
end

local create_object = prototypify(CircularBuffer)
return {
   new = function(size)
      assert(type(size) == "number")
      assert(size >= 1, "buffer size must be one or more")

      return create_object({
         size = size,

         _contents = {},
         _read_index = size + 1,
         _write_index = size + 1,
      })
   end
}
