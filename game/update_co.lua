local chase_co = require("game.systems.chase_co")
local attack_co = require("game.systems.attack_co")
local move_by_input_co = require("game.systems.move_by_input_co")
local warp_by_input_co = require("game.systems.warp_by_input_co")

return function(levels_config, entity_manager, player_input)
   local chase = coroutine.wrap(chase_co)
   local attack = coroutine.wrap(attack_co)
   local move_by_input = coroutine.wrap(move_by_input_co)
   local warp_by_input = coroutine.wrap(warp_by_input_co)

   -- Initialize
   chase(levels_config, entity_manager)
   attack(levels_config, entity_manager)
   move_by_input(levels_config, entity_manager, player_input)
   warp_by_input(levels_config, entity_manager, player_input)

   while true do
      local dt = coroutine.yield()
      chase(dt)
      attack(dt)
      move_by_input()
      warp_by_input()
   end
end
