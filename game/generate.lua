local generate_altars = require("game.generate.generate_altars")
local generate_gems = require("game.generate.generate_gems")
local generate_player = require("game.generate.generate_player")
local generate_tiles = require("game.generate.generate_tiles")

--s entity.EntityManager -> table -> nil
return function(entity_manager, config)
   generate_tiles(entity_manager, config.levels)
   generate_player(entity_manager, config.player)
   generate_gems(entity_manager, config.levels)
   generate_altars(entity_manager, config.levels)
end
