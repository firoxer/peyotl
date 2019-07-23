local Point = require("game.data_structures.point")
local create_component = require("game.entity.create_component")

return function(entity_manager, player_config)
   local id = entity_manager:new_entity_id()
   entity_manager:add_component(id, create_component.position("underground", Point.new(5, 5)))
   entity_manager:add_component(id, create_component.health(player_config.initial_health, player_config.max_health))
   entity_manager:add_component(id, create_component.input())
   entity_manager:add_component(id, create_component.camera())
   entity_manager:add_component(id, create_component.render("underground_player", 2))
end
