local chase_co = require("game.systems.chase_co")
local attack_co = require("game.systems.attack_co")
local move_by_input_co = require("game.systems.move_by_input_co")
local warp_by_input_co = require("game.systems.warp_by_input_co")

return function(levels_config, entity_manager, player_input)
   local chase = chase_co(levels_config, entity_manager)
   local attack = attack_co(levels_config, entity_manager)
   local move_by_input = move_by_input_co(levels_config, entity_manager, player_input)
   local warp_by_input = warp_by_input_co(levels_config, entity_manager, player_input)

   return coroutine.wrap(function(dt)
      while true do
         chase(dt)
         attack(dt)
         move_by_input()
         warp_by_input()

         dt = coroutine.yield()
      end
   end)
end
