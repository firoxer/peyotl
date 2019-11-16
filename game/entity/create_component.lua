return {
   attack = function(amount, time_between_attacks, time_since_last_attack)
      return {
         name = "attack",
         amount = amount,
         time_between_attacks = time_between_attacks,
         time_since_last_attack = time_since_last_attack,
      }
   end,

   camera = function()
      return {
         name = "camera"
      }
   end,

   chase = function(target_id)
      return {
         name = "chase",
         target_id = target_id,
         time_at_last_movement = 0,
      }
   end,

   collision = function()
      return {
         name = "collision",
      }
   end,

   health = function(amount, max_amount)
      return {
         name = "health",
         amount = amount,
         max_amount = max_amount,
      }
   end,

   input = function()
      return {
         name = "input",
      }
   end,

   opaque = function()
      return {
         name = "opaque",
      }
   end,

   position = function(level, point)
      return {
         name = "position",
         level = level,
         point = point,
      }
   end,

   render = function(tileset_quad_name, layer)
      return {
         name = "render",
         tileset_quad_name = tileset_quad_name,
         layer = layer,
      }
   end
}
