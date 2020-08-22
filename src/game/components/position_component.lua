local Component = require("src.engine.ecs.component")

local PositionComponent = prototype(
   Component("position"),
   function(self, point)
      assertx.is_instance_of("ds.Point", point)

      self.point = point
   end
)

return PositionComponent
