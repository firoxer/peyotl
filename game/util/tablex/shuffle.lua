-- Fisher-Yates, taken from https://gist.github.com/Uradamus/10323382
return function(tbl)
   assertx.is_table(tbl)

   for i = #tbl, 2, -1 do
      local j = love.math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
   end

   return tbl
end
