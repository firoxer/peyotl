local Component = require("src.engine.ecs.component")

local FogOfWarComponent = prototype(
   Component("fog_of_war"),
   function(self, explored)
      assertx.is_boolean_or_nil(explored)

      self.explored = explored or false
   end
)

return FogOfWarComponent
