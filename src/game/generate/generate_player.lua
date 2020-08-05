local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

return function(em, player_config)
   local id = em:new_entity_id()

   em:add_component(id, components.health(player_config.initial_health, player_config.max_health))
   em:add_component(id, components.input())
   em:add_component(id, components.camera())
   em:add_component(id, components.chaseable())
   em:add_component(id, components.player())
   em:add_component(id, components.render(tile_names.player, 2))

   return id
end
