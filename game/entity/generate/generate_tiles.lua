local carve_into_preset_temple = require("game.entity.generate.tiles.carve_into_preset_temple")
local carve_with_cellular_automatons = require("game.entity.generate.tiles.carve_with_cellular_automatons")
local carve_with_random_squares = require("game.entity.generate.tiles.carve_with_random_squares")
local carve_with_simplex_noise = require("game.entity.generate.tiles.carve_with_simplex_noise")
local create_component = require("game.entity.create_component")
local measure_time = require("game.util.measure_time")
local tileset_quad_names = require("game.render.tileset_quad_names")

local carves_by_algorithm_name = {
   simplex = carve_with_simplex_noise,
   random_squares = carve_with_random_squares,
   cellular_automatons = carve_with_cellular_automatons,
   preset_temple = carve_into_preset_temple,
}

local function change_south_wall_tiles_quad(em, render_cs)
   for entity_id, position_c, render_c in em:iterate("position", "render") do
      if render_c.tileset_quad_name == "temple_wall" then
         local render_c_south = render_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            render_c_south.tileset_quad_name == tileset_quad_names.temple_empty
            or render_c_south.tileset_quad_name == tileset_quad_names.temple_empty2
         then
            em:update_component(entity_id, "render", {
               tileset_quad_name = tileset_quad_names.temple_wall_south
            })
         end
      elseif render_c.tileset_quad_name == "dungeon_wall" then
         local render_c_south = render_cs:get(ds.Point.offset(position_c.point, 0, 1))
         if
            render_c_south
            and (
               render_c_south.tileset_quad_name == tileset_quad_names.dungeon_empty
               or render_c_south.tileset_quad_name == tileset_quad_names.dungeon_empty2
            )
         then
            em:update_component(entity_id, "render", {
               tileset_quad_name = tileset_quad_names.dungeon_wall_south
            })
         end
      end
   end
end

return function(em, level_name, level_config)
   measure_time.start()

   local current_time = love.timer.getTime()
   local render_cs = ds.Matrix.new()

   local carve = carves_by_algorithm_name[level_config.generation.algorithm]
   if carve == nil then
      error("unknown map generation algorithm: " .. level_config.generation.algorithm)
   end
   local matrix = carve(level_config.generation, level_config.width, level_config.height)
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
            tileset_quad_name = tablex.sample({
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty,
               tileset_quad_names.temple_empty2,
            })
         else
            tileset_quad_name = tablex.sample({
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

      local tile_id = em:new_entity_id()
      em:add_component(tile_id, create_component.position(point))
      local render_c = create_component.render(tileset_quad_name, 0)
      em:add_component(tile_id, render_c)
      render_cs:set(point, render_c)

      if is_wall then
         em:add_component(tile_id, create_component.collision())
         em:add_component(tile_id, create_component.opaque())
      end

      if level_config.lighting and level_config.lighting.fog_of_war then
         em:add_component(tile_id, create_component.fog_of_war())
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
            chase_target_id = em:get_registered_entity_id("player")
         elseif level_config.monsters.chase_target == "altar" then
            -- FIXME
            local altar_1_id = em:get_registered_entity_id("altar_1")
            local altar_2_id = em:get_registered_entity_id("altar_2")
            local altar_3_id = em:get_registered_entity_id("altar_3")
            local altar_4_id = em:get_registered_entity_id("altar_4")
            if altar_1_id == nil or altar_2_id == nil or altar_3_id == nil or altar_4_id == nil then
               log.warn("one or more altars not set, skipping monster spawning")
            else
               chase_target_id = tablex.sample({ altar_1_id, altar_2_id, altar_3_id, altar_4_id })
            end
         else
            error("unknown monster chase target: " .. level_config.monsters.chase_target)
         end

         if chase_target_id then
            local spawn_offset =
               current_time - (love.math.random() * level_config.monsters.spawning.seconds_per_spawn)
            em:add_component(
               tile_id,
               create_component.monster_spawning(chase_target_id, spawn_offset)
            )
         end
      end
   end

   change_south_wall_tiles_quad(em, render_cs)

   measure_time.stop_and_log(level_name .. " generated")
end
