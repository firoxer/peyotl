return function(player_config, entity_manager, components, sprite_quads)
   local id = entity_manager:new_entity_id()

   local initial_health = player_config.initial_health
   local max_health = player_config.max_health

   entity_manager:add_component(id, components.Health(initial_health, max_health))
   entity_manager:add_component(id, components.Input())
   entity_manager:add_component(id, components.Camera())
   entity_manager:add_component(id, components.Chaseable())
   entity_manager:add_component(id, components.Player())
   entity_manager:add_component(id, components.Sprite(sprite_quads.player1, 3))

   return id
end
