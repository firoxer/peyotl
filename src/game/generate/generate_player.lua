local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

return function(entity_manager, player_config)
   local id = entity_manager:new_entity_id()

   entity_manager:add_component(id, components.health(player_config.initial_health, player_config.max_health))
   entity_manager:add_component(id, components.input())
   entity_manager:add_component(id, components.camera())
   entity_manager:add_component(id, components.chaseable())
   entity_manager:add_component(id, components.player())
   entity_manager:add_component(id, components.texture(tile_names.player, 2))

   return id
end
