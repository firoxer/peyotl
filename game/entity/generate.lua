local generate_gems = require("game.entity.generate.generate_gems")
local generate_player = require("game.entity.generate.generate_player")
local generate_tiles = require("game.entity.generate.generate_tiles")

return function(em, level_config)
   em:flush()

   generate_tiles(em, level_config)

   generate_player(em, level_config.player)

   if level_config.gems then
      generate_gems(em, level_config.gems)
   end
end
