do
   local tbl = tablex.uptight({ a = 1 })
   assert(tbl.a == 1)
end

do
   local tbl = tablex.uptight({ a = 1 })
   local _, err = pcall(function() return tbl.b end)
   assert(err ~= nil)
end
