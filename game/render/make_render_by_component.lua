--- Technically this should go under systems/ but this way it just makes more sense

local round = mathx.round

local create_calculate_alpha = require("game.render.create_calculate_alpha")

local function create_render_layers(matrix_iterator)
   local layer_ids = {}
   local layers_by_id = {}

   for point, layer in matrix_iterator do
      for _, render_c in pairs(layer) do
         if not layers_by_id[render_c.layer] then
            layers_by_id[render_c.layer] = ds.Matrix()
            table.insert(layer_ids, render_c.layer)
         end

         layers_by_id[render_c.layer]:set(point, render_c)
      end
   end

   return layer_ids, layers_by_id
end

local function create_illuminabilities(render_matrix_iterator, opaque_matrix)
   local illuminabilities = ds.Matrix()

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

return function(rendering_config, level_config, em, tileset)
   assertx.is_table(rendering_config)
   assertx.is_table(level_config)
   assertx.is_instance_of("entity.EntityManager", em)
   assertx.is_table(tileset)

   local camera_rigidness = rendering_config.camera_rigidness
   local window_width = rendering_config.window.width
   local window_height = rendering_config.window.height
   local tile_size = rendering_config.tiles.size
   local tileset_draw_rounding = 1 / tile_size

   local current_camera_x = 0
   local current_camera_y = 0

   -- Canvas is used so that everything can be rendered 1x and then scaled up
   local canvas = love.graphics.newCanvas(window_width * tile_size, window_height * tile_size)
   canvas:setFilter("nearest", "nearest")

   local tileset_batch = love.graphics.newSpriteBatch(tileset.image, window_width * window_height)

   local render_matrix = ds.Matrix()
   em.subject:subscribe_to_any_change_of(
      { "render", "position" },
      function(event_data, render_c, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            if render_matrix:has(position_c.point) then
               render_matrix:get(position_c.point)[render_c.layer] = nil
            end
            local updated_layer = render_matrix:get(event_data.updated_fields.point)
            if not updated_layer then
               updated_layer = {}
            end
            updated_layer[render_c.layer] = render_c
            render_matrix:set(event_data.updated_fields.point, updated_layer)
         else
            local updated_layer = render_matrix:get(position_c.point)
            if not updated_layer then
               updated_layer = {}
            end
            updated_layer[render_c.layer] = render_c
            render_matrix:set(position_c.point, updated_layer)
         end
      end
   )

   local opaque_matrix = ds.Matrix()
   em.subject:subscribe_to_any_change_of(
      { "opaque", "position" },
      function(event_data, _, position_c)
         if event_data.updated_fields and event_data.updated_fields.point then
            opaque_matrix:set(position_c.point, opaque_matrix:get(position_c.point) - 1)
            opaque_matrix:set(
               event_data.updated_fields.point,
               opaque_matrix:get(event_data.updated_fields.point) + 1
            )
         else
            opaque_matrix:set(position_c.point, (opaque_matrix:get(position_c.point) or 0) + 1)
         end
      end
   )

   local entity_ids_by_render_c = {}
   em.subject:subscribe_to_any_change_of(
      { "render" },
      function(event_data, render_c)
         entity_ids_by_render_c[render_c] = event_data.entity_id
      end
   )

   local time_at_last_render = 0
   return function()
      local camera_entity_position_c =
         em:get_component(em:get_unique_component("camera"), "position")

      local camera_entity_position_point = camera_entity_position_c.point
      if love.timer.getTime() - time_at_last_render < 0.5 then
         -- By moving the camera only a bit at a time, it gets nice and sticky
         -- and it follows its target more naturally
         current_camera_x = current_camera_x + (camera_entity_position_point.x - current_camera_x) * camera_rigidness
         current_camera_y = current_camera_y + (camera_entity_position_point.y - current_camera_y) * camera_rigidness
      else
         -- If too much time has passed since the last render, the stickiness
         -- would likely look weird
         current_camera_x = camera_entity_position_point.x
         current_camera_y = camera_entity_position_point.y
      end

      local visible_nw_se_corners = {
         current_camera_x - (window_width / 2) - 1,
         current_camera_y - (window_height / 2) - 1,
         current_camera_x + (window_width / 2),
         current_camera_y + (window_height / 2)
      }
      local visible_render_matrix_iterator =
         render_matrix:submatrix_pairs(unpack(visible_nw_se_corners))
      local layer_ids, layers_by_id =
         create_render_layers(visible_render_matrix_iterator)

      table.sort(layer_ids)

      visible_render_matrix_iterator =
         render_matrix:submatrix_pairs(unpack(visible_nw_se_corners))
      local illuminabilities =
         create_illuminabilities(visible_render_matrix_iterator, opaque_matrix)

      local calculate_alpha =
         create_calculate_alpha(level_config.lighting, illuminabilities, camera_entity_position_c.point)

      love.graphics.setCanvas(canvas)

      -- The background has to be rendered here so that the alphas
      -- go nicely on top of it
      love.graphics.clear(level_config.background_color)

      for _, layer_id in ipairs(layer_ids) do
         local renderables = layers_by_id[layer_id]

         tileset_batch:clear()
         for point, render_c in renderables:pairs() do
            local alpha = calculate_alpha(point)

            local entity_id = entity_ids_by_render_c[render_c]
            if em:has_component(entity_id, "fog_of_war") then
               local fow_c = em:get_component(entity_id, "fog_of_war")
               if fow_c.explored and alpha < level_config.lighting.explored_alpha then
                  alpha = level_config.lighting.explored_alpha
               elseif alpha > 0 and not fow_c.explored then
                  em:update_component(entity_id, "fog_of_war", { explored = true })
               end
            end

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

      time_at_last_render = love.timer.getTime()
   end
end
