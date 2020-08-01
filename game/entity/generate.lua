local generate_gems = require("game.entity.generate.generate_gems")
local generate_player = require("game.entity.generate.generate_player")
local generate_tiles = require("game.entity.generate.generate_tiles")
local place_player_on_tiles = require("game.entity.generate.place_player_on_tiles")

return function(em, level_config)
   em:flush()

   local player_id = generate_player(em, level_config.player)

   generate_tiles(em, level_config)

   place_player_on_tiles(em, player_id)

   if level_config.gems then
      generate_gems(em, level_config.gems)
   end
end
