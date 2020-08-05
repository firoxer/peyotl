local function find_free_position_c(em)
   local free_positions = {}
   for tile_entity_id, position_c in em:iterate("position") do
      if em:get_component(tile_entity_id, "collision") == nil then
         table.insert(free_positions, position_c)
      end
   end

   if #free_positions == 0 then
      error("no position to place player on")
   end

   return tablex.clone(tablex.sample(free_positions))
end

return function(em, player_id)
   em:add_component(player_id, find_free_position_c(em))
end