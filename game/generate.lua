local generate_monsters = require("game.generate.generate_monsters")
local generate_player = require("game.generate.generate_player")
local generate_tiles = require("game.generate.generate_tiles")

return function(entity_manager, config)
   generate_tiles(entity_manager, config.levels)
   generate_player(entity_manager, config.player)
   generate_monsters(entity_manager, config.levels)
end
