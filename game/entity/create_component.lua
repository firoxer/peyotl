local components = require("game.entity.components")

return {
   [components.camera] = function()
      return {
         name = components.camera,
      }
   end,

   [components.chase] = function(target)
      return {
         name = components.chase,
         target = target,
         time_since_last_movement = math.huge,
      }
   end,

   [components.collision] = function()
      return {
         name = components.collision,
      }
   end,

   [components.health] = function(amount, max_amount)
      return {
         name = components.health,
         amount = amount,
         max_amount = max_amount,
      }
   end,

   [components.input] = function()
      return {
         name = components.input,
      }
   end,

   [components.opaque] = function()
      return {
         name = components.opaque,
      }
   end,

   [components.position] = function(level, point)
      return {
         name = components.position,
         level = level,
         point = point,
      }
   end,

   [components.render] = function(tileset_quad_name, layer)
      return {
         name = components.render,
         tileset_quad_name = tileset_quad_name,
         layer = layer,
      }
   end
}
