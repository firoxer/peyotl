local carve_into_preset_temple = require("src.game.generate.generate_tiles.carve_into_preset_temple")
local carve_with_cellular_automatons = require("src.game.generate.generate_tiles.carve_with_cellular_automatons")
local carve_with_random_squares = require("src.game.generate.generate_tiles.carve_with_random_squares")
local carve_with_simplex_noise = require("src.game.generate.generate_tiles.carve_with_simplex_noise")
local components = require("src.game.components")
local tile_names = require("src.game.tileset.tile_names")

local carves_by_algorithm_name = {
   simplex = carve_with_simplex_noise,
   random_squares = carve_with_random_squares,
   cellular_automatons = carve_with_cellular_automatons,
   preset_temple = carve_into_preset_temple,
}

local function change_south_wall_tiles_quad(em, render_cs)
   for entity_id, position_c, render_c in em:iterate("position", "render") do
      if render_c.tile_name == "wall" then
         local render_c_south = render_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            render_c_south
            and (
               render_c_south.tile_name == tile_names.empty
               or render_c_south.tile_name == tile_names.empty2
            )
         then
            em:update_component(entity_id, "render", {
               tile_name = tile_names.wall_south
            })
         end
      elseif render_c.tile_name == "wall" then
         local render_c_south = render_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            render_c_south
            and (
               render_c_south.tile_name == tile_names.empty
               or render_c_south.tile_name == tile_names.empty2
            )
         then
            em:update_component(entity_id, "render", {
               tile_name = tile_names.wall_south
            })
         end
      end
   end
end

return function(em, level_config)
   local current_time = love.timer.getTime()
   local render_cs = ds.Matrix()

   local carve = carves_by_algorithm_name[level_config.tiles.algorithm]
   if carve == nil then
      error("unknown map generation algorithm: " .. level_config.tiles.algorithm)
   end
   local matrix = carve(level_config.tiles, level_config.width, level_config.height)
   for point, is_wall in matrix:pairs() do
      local tile_name
      if is_wall then
         tile_name = tile_names.wall
      else
         tile_name = tablex.sample({
            tile_names.empty,
            tile_names.empty,
            tile_names.empty,
            tile_names.empty,
            tile_names.empty,
            tile_names.empty,
            tile_names.empty2,
         })
      end

      local tile_id = em:new_entity_id()
      em:add_component(tile_id, components.position(point))
      local render_c = components.render(tile_name, 0)
      em:add_component(tile_id, render_c)
      render_cs:set(point, render_c)

      if is_wall then
         em:add_component(tile_id, components.collision())
         em:add_component(tile_id, components.opaque())
      end

      if level_config.lighting and level_config.lighting.fog_of_war then
         em:add_component(tile_id, components.fog_of_war())
      end

      if level_config.monsters and not is_wall then
         local chase_target_id
         if level_config.monsters.chase_target == "player" then
            chase_target_id = em:get_unique_component("player")
         else
            error("unknown monster chase target: " .. level_config.monsters.chase_target)
         end

         if chase_target_id then
            local spawn_offset =
               current_time - (love.math.random() * level_config.monsters.spawning.seconds_per_spawn)
            em:add_component(
               tile_id,
               components.monster_spawning(chase_target_id, spawn_offset)
            )
         end
      end
   end

   change_south_wall_tiles_quad(em, render_cs)
end
