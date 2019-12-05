local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

local function find_free_position_c(entity_manager, level)
   local free_positions = {}
   for tile_entity_id, position_c in entity_manager:iterate("position") do
      if entity_manager:get_component(tile_entity_id, "collision") == nil
         and position_c.level == level
      then
         table.insert(free_positions, position_c)
      end
   end

   if #free_positions == 0 then
      error("no position to place player on")
   end

   return tablex.clone(tablex.sample(free_positions))
end

return function(entity_manager, player_config)
   local position_c = find_free_position_c(entity_manager, "temple") -- TODO: Dehardcore "temple"

   local id = entity_manager:get_registered_entity_id("player")
   entity_manager:add_component(id, position_c)
   entity_manager:add_component(id, create_component.health(player_config.initial_health, player_config.max_health))
   entity_manager:add_component(id, create_component.input())
   entity_manager:add_component(id, create_component.camera())
   entity_manager:add_component(id, create_component.render(tileset_quad_names.player_temple, 2))
end
