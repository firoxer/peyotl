return {
   attack = function(amount, time_between_attacks, time_at_last_attack)
      assertx.is_number(amount)
      assertx.is_number(time_between_attacks)
      assertx.is_number_or_nil(time_at_last_attack)

      time_at_last_attack = time_at_last_attack or 0

      return {
         name = "attack",
         amount = amount,
         range = 1,
         time_at_last_attack = time_at_last_attack,
         time_between_attacks = time_between_attacks,
      }
   end,

   camera = function()
      return {
         name = "camera"
      }
   end,

   chase = function(target_id, aggro_range)
      assertx.is_number(target_id)
      assertx.is_number(aggro_range)

      return {
         name = "chase",
         aggro_range = aggro_range,
         target_id = target_id,
         time_at_last_movement = 0,
         time_between_movements = 1,
      }
   end,

   chaseable = function()
      return {
         name = "chaseable"
      }
   end,

   collision = function()
      return {
         name = "collision",
      }
   end,

   fog_of_war = function(explored)
      assertx.is_boolean_or_nil(explored)

      explored = explored or false

      return {
         name = "fog_of_war",
         explored = explored,
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
         pending_events = ds.Queue(),
      }
   end,

   monster = function()
      return {
         name = "monster"
      }
   end,

   monster_spawning = function(chase_target_id, time_at_last_spawn)
      assertx.is_number(chase_target_id)
      assertx.is_number_or_nil(time_at_last_spawn)

      return {
         name = "monster_spawning",
         chase_target_id = chase_target_id,
         time_at_last_spawn = time_at_last_spawn or 0,
      }
   end,

   opaque = function()
      return {
         name = "opaque",
      }
   end,

   player = function()
      return {
         name = "player"
      }
   end,

   position = function(point)
      assertx.is_instance_of("ds.Point", point)

      return {
         name = "position",
         point = point,
      }
   end,

   render = function(tile_name, layer)
      assertx.is_string(tile_name)
      assertx.is_number(layer)

      return {
         name = "render",
         tile_name = tile_name,
         layer = layer,
      }
   end
}
