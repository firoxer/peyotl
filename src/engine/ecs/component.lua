local Component = prototype(function(self, name)
   assertx.is_string(name)

   self.name = name
end)

return Component