local function find_free_position_c(entity_manager)
   local free_positions = {}
   for tile_entity_id, position_c in entity_manager:iterate("position") do
      if entity_manager:get_component(tile_entity_id, "collision") == nil then
         table.insert(free_positions, position_c)
      end
   end

   if #free_positions == 0 then
      error("no position to place player on")
   end

   return tablex.clone(tablex.sample(free_positions))
end

return function(entity_manager, player_id)
   entity_manager:add_component(player_id, find_free_position_c(entity_manager))
end