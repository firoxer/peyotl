local component_names = require("game.entity.component_names")

return {
   [component_names.attack] = function(amount, time_between_attacks, time_since_last_attack)
      return {
         name = component_names.attack,
         amount = amount,
         time_between_attacks = time_between_attacks,
         time_since_last_attack = time_since_last_attack,
      }
   end,

   [component_names.camera] = function()
      return {
         name = component_names.camera,
      }
   end,

   [component_names.chase] = function(target_id)
      return {
         name = component_names.chase,
         target_id = target_id,
         time_at_last_movement = 0,
      }
   end,

   [component_names.collision] = function()
      return {
         name = component_names.collision,
      }
   end,

   [component_names.health] = function(amount, max_amount)
      return {
         name = component_names.health,
         amount = amount,
         max_amount = max_amount,
      }
   end,

   [component_names.input] = function()
      return {
         name = component_names.input,
      }
   end,

   [component_names.opaque] = function()
      return {
         name = component_names.opaque,
      }
   end,

   [component_names.position] = function(level, point)
      return {
         name = component_names.position,
         level = level,
         point = point,
      }
   end,

   [component_names.render] = function(tileset_quad_name, layer)
      return {
         name = component_names.render,
         tileset_quad_name = tileset_quad_name,
         layer = layer,
      }
   end
}
