local CircularBuffer = require("../game/data_structures/circular_buffer")

do
   local b = CircularBuffer.new(4)
   b:write("a")
   b:write("b")
   b:write("c")
   b:write("d")

   assert(b:read() == "a")
   assert(b:read() == "b")
   assert(b:read() == "c")
   assert(b:read() == "d")
   local _, err = pcall(function() b:read() end)
   assert(err ~= nil)
end

do
   local b = CircularBuffer.new(3)
   b:write("a")
   b:write("b")
   b:write("c")
   local _, err = pcall(function() b:write("d") end)
   assert(err ~= nil)
end

do
   local b = CircularBuffer.new(4)
   b:write("a")
   b:write("b")
   b:write("c")
   b:write("d")

   local count = 0
   for _, elem in b:ipairs() do
      count = count + 1
      assert(elem == "a" or elem == "b" or elem == "c" or elem == "d")
   end
   assert(count == 4)
end
