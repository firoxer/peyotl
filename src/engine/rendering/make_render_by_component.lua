--- Technically this should go under systems/ but this way it just makes more sense

local create_calculate_alpha = require("src.engine.rendering.create_calculate_alpha")

local function create_texture_layers(matrix_iterator)
   local layer_ids = {}
   local layers_by_id = {}

   for point, layer in matrix_iterator do
      for _, texture_c in pairs(layer) do
         if not layers_by_id[texture_c.layer] then
            layers_by_id[texture_c.layer] = ds.Matrix()
            table.insert(layer_ids, texture_c.layer)
         end

         layers_by_id[texture_c.layer]:set(point, texture_c)
      end
   end

   return layer_ids, layers_by_id
end

local function create_illuminabilities(texture_matrix_iterator, opaque_matrix)
   local illuminabilities = ds.Matrix()

   for point in texture_matrix_iterator do
      local opaque_c_n = opaque_matrix:get(point) or 0
      illuminabilities:set(point, opaque_c_n == 0)
   end

   for point in illuminabilities:pairs() do
      local has_illuminable_neighbor = false
      for neighbor in pairs(illuminabilities:get_immediate_neighbors(point, true)) do
         if illuminabilities:get(neighbor) == true then
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

return function(rendering_config, level_config, entity_manager, tileset)
   assertx.is_table(rendering_config)
   assertx.is_table(level_config)
   assertx.is_instance_of("engine.ecs.EntityManager", entity_manager)
   assertx.is_table(tileset)

   local window_width = rendering_config.window.width
   local window_height = rendering_config.window.height
   local tile_size = rendering_config.tiles.size
   local tileset_draw_rounding = 1 / tile_size

   -- Canvas is used so that everything can be rendered 1x and then scaled up
   local canvas = love.graphics.newCanvas(window_width * tile_size, window_height * tile_size)
   canvas:setFilter("nearest", "nearest")

   local tileset_batch = love.graphics.newSpriteBatch(tileset.image, window_width * window_height)

   local texture_matrix
   local update_texture_matrix = function()
      texture_matrix = ds.Matrix()

      for _, texture_c, position_c in entity_manager:iterate("texture", "position") do
         local updated_layer = texture_matrix:get(position_c.point)
         if not updated_layer then
            updated_layer = {}
            texture_matrix:set(position_c.point, updated_layer)
         end
         updated_layer[texture_c.layer] = texture_c
      end
   end

   local opaque_matrix
   local update_opaque_matrix = function()
      opaque_matrix = ds.Matrix()
      for _, _, position_c in entity_manager:iterate("opaque", "position") do
         opaque_matrix:set(
            position_c.point,
            (opaque_matrix:get(position_c.point) or 0) + 1
         )
      end
   end

   local entity_ids_by_texture_c = {}
   local update_entity_ids_by_texture_c = function()
      for entity_id, texture_c in entity_manager:iterate("texture") do
         entity_ids_by_texture_c[texture_c] = entity_id
      end
   end

   return function()
      local camera_point =
         entity_manager:get_component(entity_manager:get_unique_component("camera"), "position")
            .point

      update_texture_matrix()
      update_opaque_matrix()
      update_entity_ids_by_texture_c()

      local visible_nw_se_corners = {
         camera_point.x - (window_width / 2) - 1,
         camera_point.y - (window_height / 2) - 1,
         camera_point.x + (window_width / 2),
         camera_point.y + (window_height / 2)
      }
      local visible_texture_matrix_iterator =
         texture_matrix:submatrix_pairs(unpack(visible_nw_se_corners))
      local layer_ids, layers_by_id =
         create_texture_layers(visible_texture_matrix_iterator)

      table.sort(layer_ids)

      visible_texture_matrix_iterator =
         texture_matrix:submatrix_pairs(unpack(visible_nw_se_corners))
      local illuminabilities =
         create_illuminabilities(visible_texture_matrix_iterator, opaque_matrix)

      local calculate_alpha =
         create_calculate_alpha(level_config.lighting, illuminabilities, camera_point)

      love.graphics.setCanvas(canvas)

      -- The background has to be rendered here so that the alphas
      -- go nicely on top of it
      love.graphics.clear(level_config.background_color)

      for _, layer_id in ipairs(layer_ids) do
         local texture_cs = layers_by_id[layer_id]

         tileset_batch:clear()
         for point, texture_c in texture_cs:pairs() do
            local alpha = calculate_alpha(point)

            local entity_id = entity_ids_by_texture_c[texture_c]
            if entity_manager:has_component(entity_id, "fog_of_war") then
               local fow_c = entity_manager:get_component(entity_id, "fog_of_war")
               if fow_c.explored and alpha < level_config.lighting.explored_alpha then
                  alpha = level_config.lighting.explored_alpha
               elseif alpha > 0 and not fow_c.explored then
                  entity_manager:update_component(entity_id, "fog_of_war", { explored = true })
               end
            end

            if alpha > 0 then
               local offset_x =
                  mathx.round(
                     point.x - camera_point.x + (window_width / 2),
                     tileset_draw_rounding
                  )
               local offset_y =
                  mathx.round(
                     point.y - camera_point.y + (window_height / 2),
                     tileset_draw_rounding
                  )

               tileset_batch:setColor(1, 1, 1, alpha)
               tileset_batch:add(
                  tileset.quads[texture_c.tile_name],
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
