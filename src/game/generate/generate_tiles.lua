local carve_into_preset_temple = require("src.game.generate.generate_tiles.carve_into_preset_temple")
local carve_with_cellular_automatons = require("src.game.generate.generate_tiles.carve_with_cellular_automatons")
local carve_with_random_squares = require("src.game.generate.generate_tiles.carve_with_random_squares")
local carve_with_simplex_noise = require("src.game.generate.generate_tiles.carve_with_simplex_noise")

local carves_by_algorithm_name = {
   simplex = carve_with_simplex_noise,
   random_squares = carve_with_random_squares,
   cellular_automatons = carve_with_cellular_automatons,
   preset_temple = carve_into_preset_temple,
}

local function change_south_wall_tiles_quad(entity_manager, sprite_cs, sprite_quads)
   for entity_id, position_c, sprite_c in entity_manager:iterate("position", "sprite") do
      if sprite_c.quad == sprite_quads.wall then
         local sprite_c_south = sprite_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            sprite_c_south
            and (
               sprite_c_south.quad == sprite_quads.empty1
               or sprite_c_south.quad == sprite_quads.empty2
            )
         then
            entity_manager:update_component(entity_id, "sprite", {
               quad = sprite_quads.wall_south
            })
         end
      elseif sprite_c.quad == sprite_quads.wall then
         local sprite_c_south = sprite_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            sprite_c_south
            and (
               sprite_c_south.quad == sprite_quads.empty1
               or sprite_c_south.quad == sprite_quads.empty2
            )
         then
            entity_manager:update_component(entity_id, "sprite", {
               quad = sprite_quads.wall_south
            })
         end
      end
   end
end

return function(world_config, entity_manager, components, sprite_quads)
   local tiles_config = world_config.tiles

   local current_time = love.timer.getTime()
   local sprite_cs = ds.Matrix()

   local carve = carves_by_algorithm_name[tiles_config.algorithm]
   if carve == nil then
      error("unknown map generation algorithm: " .. tiles_config.algorithm)
   end
   local matrix = carve(tiles_config, world_config.width, world_config.height)
   for point, is_wall in matrix:pairs() do
      local quad
      if is_wall then
         quad = sprite_quads.wall
      else
         quad = tablex.sample({
            sprite_quads.empty1,
            sprite_quads.empty1,
            sprite_quads.empty1,
            sprite_quads.empty2,
         })
      end

      local tile_id = entity_manager:new_entity_id()
      entity_manager:add_component(tile_id, components.Position(point))
      local sprite_c = components.Sprite(quad, 0)
      entity_manager:add_component(tile_id, sprite_c)
      sprite_cs:set(point, sprite_c)

      if is_wall then
         entity_manager:add_component(tile_id, components.Collision())
         entity_manager:add_component(tile_id, components.Opaque())
      end

      if world_config.lighting and world_config.lighting.fog_of_war then
         entity_manager:add_component(tile_id, components.FogOfWar())
      end

      if world_config.monsters and not is_wall then
         local chase_target_id
         if world_config.monsters.chase_target == "player" then
            chase_target_id = entity_manager:get_unique_component("player")
         else
            error("unknown monster chase target: " .. world_config.monsters.chase_target)
         end

         if chase_target_id then
            local spawn_offset =
               current_time - (love.math.random() * world_config.monsters.spawning.seconds_per_spawn)
            entity_manager:add_component(
               tile_id,
               components.MonsterSpawning(chase_target_id, spawn_offset)
            )
         end
      end
   end

   change_south_wall_tiles_quad(entity_manager, sprite_cs, sprite_quads)
end
