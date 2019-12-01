local carve_into_preset_temple = require("game.generate.tiles.carve_into_preset_temple")
local carve_with_cellular_automatons = require("game.generate.tiles.carve_with_cellular_automatons")
local carve_with_random_squares = require("game.generate.tiles.carve_with_random_squares")
local carve_with_simplex_noise = require("game.generate.tiles.carve_with_simplex_noise")
local create_component = require("game.entity.create_component")
local tileset_quad_names = require("game.render.tileset_quad_names")

return function(entity_manager, levels_config)
   for level_name, level_config in pairs(levels_config) do
      local matrix
      if level_config.generation_algorithm == "simplex" then
         matrix = carve_with_simplex_noise(level_config)
      elseif level_config.generation_algorithm == "random_squares" then
         matrix = carve_with_random_squares(level_config)
      elseif level_config.generation_algorithm == "cellular_automatons" then
         matrix = carve_with_cellular_automatons(level_config)
      elseif level_config.generation_algorithm == "preset_temple" then
         matrix = carve_into_preset_temple(level_config)
      else
         error("unknown map generation algorithm: " .. level_config.generation_algorithm)
      end
      for point, is_wall in matrix:pairs() do
         local tileset_quad_name
         if is_wall then
            if level_name == "temple" then -- TODO: Dehardcore "temple"
               tileset_quad_name = "temple_wall"
            else
               tileset_quad_name = "dungeon_wall"
            end
         else
            if level_name == "temple" then
               tileset_quad_name = table.sample({
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty,
                  tileset_quad_names.temple_empty2,
               })
            else
               tileset_quad_name = table.sample({
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty,
                  tileset_quad_names.dungeon_empty2,
               })
            end
         end

         local tile_id = entity_manager:new_entity_id()
         entity_manager:add_component(tile_id, create_component.position(level_name, point))
         entity_manager:add_component(tile_id, create_component.render(tileset_quad_name, 0))

         if is_wall then
            entity_manager:add_component(tile_id, create_component.collision())
            entity_manager:add_component(tile_id, create_component.opaque())
         end

         if level_name == "dungeon" then -- FIXME
            --entity_manager:add_component(tile_id, create_component.fog_of_war())
         end

         if -- TODO: Refactor
            level_config.monsters
            and (
               (level_config.monsters.spawning.location == "bottom_edge" and point.y == level_config.height)
               or (level_config.monsters.spawning.location == "everywhere" and not is_wall)
            )
         then
            local chase_target_id
            if level_config.monsters.chase_target == "player" then
               chase_target_id = entity_manager:get_registered_entity_id("player")
            elseif level_config.monsters.chase_target == "altar" then
               chase_target_id = table.sample({ -- FIXME
                  entity_manager:get_registered_entity_id("altar_1"),
                  entity_manager:get_registered_entity_id("altar_2"),
                  entity_manager:get_registered_entity_id("altar_3"),
                  entity_manager:get_registered_entity_id("altar_4"),
               })
            else
               error("unknown monster chase target: " .. level_config.monsters.chase_target)
            end

            local preloaded_spawn_time = love.math.random() * level_config.monsters.spawning.seconds_per_spawn
            entity_manager:add_component(
               tile_id,
               create_component.monster_spawning(chase_target_id, preloaded_spawn_time)
            )
         end
      end
   end
end
