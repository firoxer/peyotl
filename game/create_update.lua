local create_chase = require("game.systems.create_chase")
local create_attack = require("game.systems.create_attack")
local create_move_by_input = require("game.systems.create_move_by_input")
local create_warp_by_input = require("game.systems.create_warp_by_input")

return function(levels_config, entity_manager)
   return function()
      local chase = coroutine.wrap(create_chase(levels_config, entity_manager))
      local attack = coroutine.wrap(create_attack(levels_config, entity_manager))
      local move_by_input = coroutine.wrap(create_move_by_input(levels_config, entity_manager))
      local warp_by_input = coroutine.wrap(create_warp_by_input(levels_config, entity_manager))

      -- Initialize
      chase()
      attack()
      move_by_input()
      warp_by_input()

      while true do
         local dt = coroutine.yield()
         chase(dt)
         attack(dt)
         move_by_input()
         warp_by_input()
      end
   end
end
