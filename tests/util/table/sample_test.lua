require("../../../init")

love = {
   math = {
      random = math.random
   }
}

do
   local tbl = { 1, 2, 3 }
   local s = table.sample(tbl)
   assert(s == 1 or s == 2 or s == 3)
end

do
   local tbl = { a = 1, b = 2, c = 3 }
   local s = table.sample(tbl)
   assert(s == 1 or s == 2 or s == 3)
end

do
   local _, err = pcall(function() table.sample({}) end)
   assert(err ~= nil)
end
