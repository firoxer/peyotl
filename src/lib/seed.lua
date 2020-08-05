local seed = nil

return function(value)
   if value ~= nil then
      assertx.is_number(value)
      seed = value
   end

   if seed == nil then
      math.randomseed(os.time())
      seed = math.random() * ((2^51) - 1)
   end

   seed = seed + 1
   math.randomseed(seed)
   love.math.setRandomSeed(seed)
end
