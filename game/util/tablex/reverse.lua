-- Taken from https://forums.coronalabs.com/topic/61784-function-for-reversing-table-order/
return function(tbl)
   assertx.is_table(tbl)

   local i = 1
   local j = #tbl

   while i < j do
      tbl[i], tbl[j] = tbl[j], tbl[i]

      i = i + 1
      j = j - 1
   end
end
