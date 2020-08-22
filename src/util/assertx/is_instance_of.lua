local function is_instance_of(prototype_name, value)
   if type(value) ~= "table" or value.prototype == nil then
      error("value should be an instance of " .. prototype_name .. ", was " .. type(value), 2)
   end

   if value.prototype.prototype_name ~= prototype_name then
      local ancestor_is_prototype = pcall(is_instance_of, prototype_name, value.prototype)
      if not ancestor_is_prototype then
         local compared_prototype_name = value.prototype.prototype_name or type(value)
         error("value should be an instance of " .. prototype_name .. ", was " .. compared_prototype_name,  2)
      end
   end
end

return is_instance_of
