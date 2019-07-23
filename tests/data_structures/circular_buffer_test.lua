require("../../init")

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
end

do
   local b = CircularBuffer.new(4)
   b:write("a")
   b:write("b")
   b:write("c")
   b:write("d")

   for _, elem in b:ipairs() do
      assert(elem == "a" or elem == "b" or elem == "c" or elem == "d")
   end
end
