local make_chase = require("game.make_systems.chase")
local make_attack = require("game.make_systems.attack")
local make_death = require("game.make_systems.death")
local make_move_by_input = require("game.make_systems.move_by_input")
local make_warp_by_input = require("game.make_systems.warp_by_input")

return function(levels_config, entity_manager, player_input)
   local chase = make_chase(levels_config, entity_manager)
   local attack = make_attack(levels_config, entity_manager)
   local death = make_death(levels_config, entity_manager)
   local move_by_input = make_move_by_input(levels_config, entity_manager, player_input)
   local warp_by_input = make_warp_by_input(levels_config, entity_manager, player_input)

   return function(dt)
      chase(dt)
      attack(dt)
      death()
      move_by_input()
      warp_by_input()
   end
end
