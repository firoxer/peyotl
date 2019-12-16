--- Technically this should go under systems/ but this way it just makes more sense

local round = mathx.round

local create_calculate_alpha = require("game.render.create_calculate_alpha")
local make_render_background = require("game.render.make_render_background")

local function create_render_layers(matrix_iterator)
   local layer_ids = {}
   local layers_by_id = {}

   for point, layer in matrix_iterator do
      for _, render_c in pairs(layer) do
         if not layers_by_id[render_c.layer] then
            layers_by_id[render_c.layer] = ds.Matrix.new()
            table.insert(layer_ids, render_c.layer)
         end

         layers_by_id[render_c.layer]:set(point, render_c)
      end
   end

   return layer_ids, layers_by_id
end

local function create_illuminabilities(render_matrix_iterator, opaque_matrix)
   local illuminabilities = ds.Matrix.new()

   for point in render_matrix_iterator do
      local opaque_c_n = opaque_matrix:get(point) or 0
      illuminabilities:set(point, opaque_c_n == 0)
   end

   for point in illuminabilities:pairs() do
      local has_illuminable_neighbor = false
      for neighbor_point in pairs(illuminabilities:get_immediate_neighbors(point, true)) do
         if illuminabilities:get(neighbor_point) == true then
            has_illuminable_neighbor = true
            break
         end
      end

      if not has_illuminable_neighbor then
         illuminabilities:remove(point)
      end
   end

   return illuminabilities
end

return function(rendering_config, levels_config, entity_manager, tileset)
   assertx.is_table(rendering_config)
   assertx.is_table(levels_config)
   assertx.is_instance_of("entity.EntityManager", entity_manager)
   assertx.is_table(tileset)

   local camera_rigidness = rendering_config.camera_rigidness
   local window_width = rendering_config.window.width
   local window_height = rendering_config.window.height
   local tile_size = rendering_config.tiles.size
   local tileset_draw_rounding = 1 / tile_size

   local current_camera_x = 0
   local current_camera_y = 0
   local current_camera_level = nil

   -- Canvas is used so that everything can be rendered 1x and then scaled up
   local canvas = love.graphics.newCanvas(window_width * tile_size, window_height * tile_size)
   canvas:setFilter("nearest", "nearest")

   local render_background = make_render_background(levels_config, entity_manager)

   local tileset_batch = love.graphics.newSpriteBatch(tileset.image, window_width * window_height)

   local render_matrices = {}
   for level_name in pairs(levels_config) do
      render_matrices[level_name] = ds.Matrix.new()
   end
   entity_manager.subject:subscribe_to_any_change_of(
      { "render", "position" },
      function(event_data, render_c, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            render_matrices[position_c.level]:get(position_c.point)[render_c.layer] = nil
            local updated_layer = render_matrices[position_c.level]:get(event_data.updated_fields.point)
            if not updated_layer then
               updated_layer = {}
            end
            updated_layer[render_c.layer] = render_c
            render_matrices[position_c.level]:set(event_data.updated_fields.point, updated_layer)
         else
            local updated_layer = render_matrices[position_c.level]:get(position_c.point)
            if not updated_layer then
               updated_layer = {}
            end
            updated_layer[render_c.layer] = render_c
            render_matrices[position_c.level]:set(position_c.point, updated_layer)
         end
      end
   )

   local opaque_matrices = {}
   for level_name in pairs(levels_config) do
      opaque_matrices[level_name] = ds.Matrix.new()
   end
   entity_manager.subject:subscribe_to_any_change_of(
      { "opaque", "position" },
      function(event_data, _, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            opaque_matrices[position_c.level]:set(
               position_c.point,
               opaque_matrices[position_c.level]:get(position_c.point) - 1
            )
            opaque_matrices[position_c.level]:set(
               event_data.updated_fields.point,
               opaque_matrices[position_c.level]:get(event_data.updated_fields.point) + 1
            )
         else
            opaque_matrices[position_c.level]:set(
               position_c.point,
               (opaque_matrices[position_c.level]:get(position_c.point) or 0) + 1
            )
         end
      end
   )

   return function()
      local camera_entity_position_c =
         entity_manager:get_component(entity_manager:get_unique_component("camera"), "position")

      -- By moving the camera only a bit at a time, it gets nice and sticky
      -- and it follows its target more naturally
      local camera_entity_position_point = camera_entity_position_c.point
      current_camera_x = current_camera_x + (camera_entity_position_point.x - current_camera_x) * camera_rigidness
      current_camera_y = current_camera_y + (camera_entity_position_point.y - current_camera_y) * camera_rigidness
      current_camera_level = camera_entity_position_c.level

      local level_config = levels_config[current_camera_level]

      local visible_nw_se_corners = {
         current_camera_x - (window_width / 2) - 1,
         current_camera_y - (window_height / 2) - 1,
         current_camera_x + (window_width / 2),
         current_camera_y + (window_height / 2)
      }
      local visible_render_matrix_iterator =
         render_matrices[current_camera_level]:submatrix_pairs(unpack(visible_nw_se_corners))
      local layer_ids, layers_by_id =
         create_render_layers(visible_render_matrix_iterator)

      table.sort(layer_ids)

      visible_render_matrix_iterator =
         render_matrices[current_camera_level]:submatrix_pairs(unpack(visible_nw_se_corners))
      local illuminabilities =
         create_illuminabilities(visible_render_matrix_iterator, opaque_matrices[current_camera_level])

      local calculate_alpha =
         create_calculate_alpha(level_config.lighting, illuminabilities, camera_entity_position_c.point)

      love.graphics.setCanvas(canvas)
      love.graphics.clear()

      -- The background has to be rendered here so that the alphas
      -- go nicely on top of it
      render_background()

      for _, layer_id in ipairs(layer_ids) do
         local renderables = layers_by_id[layer_id]

         tileset_batch:clear()
         for point, render_c in renderables:pairs() do
            local alpha = calculate_alpha(point)
            if alpha > 0 then
               local offset_x = round(point.x - current_camera_x + (window_width / 2), tileset_draw_rounding)
               local offset_y = round(point.y - current_camera_y + (window_height / 2), tileset_draw_rounding)

               tileset_batch:setColor(1, 1, 1, alpha)
               tileset_batch:add(
                  tileset.quads[render_c.tileset_quad_name],
                  offset_x * tile_size,
                  offset_y * tile_size
               )
            end
         end
         tileset_batch:flush()

         love.graphics.setColor(1, 1, 1, 1)
         love.graphics.draw(tileset_batch)
      end

      love.graphics.setCanvas()
      love.graphics.draw(canvas, 0, 0, 0, rendering_config.tiles.scale)
   end
end
