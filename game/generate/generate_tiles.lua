local carve_into_preset_aboveground = require("game.generate.tiles.carve_into_preset_aboveground")
local carve_with_cellular_automatons = require("game.generate.tiles.carve_with_cellular_automatons")
local carve_with_random_squares = require("game.generate.tiles.carve_with_random_squares")
local carve_with_simplex_noise = require("game.generate.tiles.carve_with_simplex_noise")
local create_component = require("game.entity.create_component")
local tile_kinds = require("game.generate.tiles.kinds")
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
      elseif level_config.generation_algorithm == "preset_aboveground" then
         matrix = carve_into_preset_aboveground(level_config)
      else
         error("unknown map generation algorithm: " .. level_config.generation_algorithm)
      end
      for point, tile_kind in matrix:pairs() do
         local tileset_quad_name
         if tile_kind == tile_kinds.wall then
            if level_name == "aboveground" then
               tileset_quad_name = "aboveground_wall"
            else
               tileset_quad_name = "underground_wall"
            end
         else
            if level_name == "aboveground" then
               tileset_quad_name = table.sample({
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty,
                  tileset_quad_names.aboveground_empty2,
               })
            else
               tileset_quad_name = table.sample({
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty,
                  tileset_quad_names.underground_empty2,
               })
            end
         end

         local tile_id = entity_manager:new_entity_id()
         entity_manager:add_component(tile_id, create_component.position(level_name, point))
         entity_manager:add_component(tile_id, create_component.render(tileset_quad_name, 0))

         if tile_kind == tile_kinds.wall then
            entity_manager:add_component(tile_id, create_component.collision())
            entity_manager:add_component(tile_id, create_component.opaque())
         end
      end
   end
end
