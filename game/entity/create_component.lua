return {
   attack = function(amount, time_between_attacks, time_since_last_attack)
      assertx.is_number(amount)
      assertx.is_number(time_between_attacks)
      assertx.is_number(time_since_last_attack)

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
      assertx.is_number(target_id)

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
      assertx.is_number(amount)
      assertx.is_number(max_amount)

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

   monster_spawning = function(chase_target_id, time_since_last_spawn)
      assertx.is_number(chase_target_id)

      return {
         name = "monster_spawning",
         chase_target_id = chase_target_id,
         time_since_last_spawn = time_since_last_spawn or 0,
      }
   end,

   opaque = function()
      return {
         name = "opaque",
      }
   end,

   position = function(level, point)
      assertx.is_string(level)
      assertx.is_instance_of("ds.Point", point)

      return {
         name = "position",
         level = level,
         point = point,
      }
   end,

   render = function(tileset_quad_name, layer)
      assertx.is_string(tileset_quad_name)
      assertx.is_number(layer)

      return {
         name = "render",
         tileset_quad_name = tileset_quad_name,
         layer = layer,
      }
   end
}
