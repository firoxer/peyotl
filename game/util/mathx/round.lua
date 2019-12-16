return function(n, multiple)
   assertx.is_number(n)
   assertx.is_number(multiple)

   return math.floor(n / multiple + 0.5) * multiple
end

