
return function(x)
   if type(x) ~= "userdata" then
      error("value should be userdata, was " .. type(x), 2)
   end
end
