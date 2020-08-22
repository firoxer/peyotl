local Component = require("src.engine.ecs.component")

local TextureComponent = prototype(
   Component("texture"),
   function(self, tile_name, layer)
      assertx.is_string(tile_name)
      assertx.is_number(layer)

      self.tile_name = tile_name
      self.layer = layer
   end
)

return TextureComponent
