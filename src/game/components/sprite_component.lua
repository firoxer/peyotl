local Component = require("src.engine.ecs.component")

local SpriteComponent = prototype(
   Component("sprite"),
   function(self, quad, layer)
      assertx.is_userdata(quad)
      assertx.is_number(layer)

      self.quad = quad
      self.layer = layer
   end
)

return SpriteComponent
