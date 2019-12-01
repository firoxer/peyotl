return {
   attack = function(amount, time_between_attacks, time_since_last_attack)
      assert(type(amount) == "number")
      assert(type(time_between_attacks) == "number")
      assert(type(time_since_last_attack) == "number")

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
      assert(type(target_id) == "number")

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
      assert(type(amount) == "number")
      assert(type(max_amount) == "number")

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
      assert(type(chase_target_id) == "number")

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
      assert(type(level) == "string")
      assert(point.type == "ds.Point")

      return {
         name = "position",
         level = level,
         point = point,
      }
   end,

   render = function(tileset_quad_name, layer)
      assert(type(tileset_quad_name) == "string")
      assert(type(layer) == "number")

      return {
         name = "render",
         tileset_quad_name = tileset_quad_name,
         layer = layer,
      }
   end
}
