local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(em, player_config)
   local id = em:new_entity_id()

   em:add_component(id, create_component.health(player_config.initial_health, player_config.max_health))
   em:add_component(id, create_component.input())
   em:add_component(id, create_component.camera())
   em:add_component(id, create_component.chaseable())
   em:add_component(id, create_component.player())
   em:add_component(id, create_component.render(tileset_quad_names.player, 2))

   return id
end
