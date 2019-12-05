do
   local tbl = { 1, 2, 3 }
   local s = tablex.sample(tbl)
   assert(s == 1 or s == 2 or s == 3)
end

do
   local tbl = { a = 1, b = 2, c = 3 }
   local s = tablex.sample(tbl)
   assert(s == 1 or s == 2 or s == 3)
end

do
   local _, err = pcall(function() tablex.sample({}) end)
   assert(err ~= nil)
end
