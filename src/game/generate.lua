local generate_gems = require("src.game.generate.generate_gems")
local generate_player = require("src.game.generate.generate_player")
local generate_tiles = require("src.game.generate.generate_tiles")
local place_player_on_tiles = require("src.game.generate.place_player_on_tiles")
local measure_time = require("src.util.measure_time")

return function(world_config, entity_manager, components, sprite_quads)
   local player_id
   measure_time.inside("player generated", function()
      player_id = generate_player(world_config.player, entity_manager, components, sprite_quads)
   end)

   measure_time.inside("tiles generated", function()
      generate_tiles(world_config, entity_manager, components, sprite_quads)
   end)

   measure_time.inside("player placed on tiles", function()
      place_player_on_tiles(entity_manager, player_id)
   end)

   if world_config.gems then
      measure_time.inside("gems generated", function()
         generate_gems(world_config.gems, entity_manager, components, sprite_quads)
      end)
   end
end
