local components = require("game.entity.components")
local create_component = require("game.entity.create_component")

local function find_free_position_c(entity_manager, level)
   local free_positions = {}
   for tile_entity_id, position_c in entity_manager:iterate(components.position) do
      if entity_manager:get_component(tile_entity_id, components.collision) == nil
         and position_c.level == level
      then
         table.insert(free_positions, position_c)
      end
   end

   if #free_positions == 0 then
      error("no position to place player on")
   end

   return table.clone(table.sample(free_positions))
end

return function(entity_manager, player_config)
   local position_c = find_free_position_c(entity_manager, "aboveground")

   local id = entity_manager:new_entity_id()
   entity_manager:add_component(id, position_c)
   entity_manager:add_component(id, create_component.health(player_config.initial_health, player_config.max_health))
   entity_manager:add_component(id, create_component.input())
   entity_manager:add_component(id, create_component.camera())
   entity_manager:add_component(id, create_component.render("underground_player", 2))
end
