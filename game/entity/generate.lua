local generate_gems = require("game.entity.generate.generate_gems")
local generate_player = require("game.entity.generate.generate_player")
local generate_tiles = require("game.entity.generate.generate_tiles")
local place_player_on_tiles = require("game.entity.generate.place_player_on_tiles")
local measure_time = require("game.util.measure_time")

return function(em, level_config)
   em:flush()

   local player_id
   measure_time.inside("player generated", function()
      player_id = generate_player(em, level_config.player)
   end)

   measure_time.inside("tiles generated", function()
      generate_tiles(em, level_config)
   end)

   measure_time.inside("player placed on tiles", function()
      place_player_on_tiles(em, player_id)
   end)

   if level_config.gems then
      measure_time.inside("gems generated", function()
         generate_gems(em, level_config.gems)
      end)
   end
end
