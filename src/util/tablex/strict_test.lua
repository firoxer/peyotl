do
   local tbl = tablex.strict({ a = 1 })
   assert(tbl.a == 1)
end

do
   local tbl = tablex.strict({ a = 1 })
   local _, err = pcall(function() return tbl.b end)
   assert(err ~= nil)
end
