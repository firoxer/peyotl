local tile_names = require("src.game.tileset.tile_names")

return function(player_config, entity_manager, components)
   local id = entity_manager:new_entity_id()

   local initial_health = player_config.initial_health
   local max_health = player_config.max_health

   entity_manager:add_component(id, components.Health(initial_health, max_health))
   entity_manager:add_component(id, components.Input())
   entity_manager:add_component(id, components.Camera())
   entity_manager:add_component(id, components.Chaseable())
   entity_manager:add_component(id, components.Player())
   entity_manager:add_component(id, components.Texture(tile_names.player, 2))

   return id
end
