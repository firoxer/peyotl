local create_calculate_alpha = require("src.engine.rendering.create_calculate_alpha")

local SpriteRenderer = prototype(function(self, rendering_config, world_config, entity_manager, sprite_atlas)
   assertx.is_table(rendering_config)
   assertx.is_table(world_config)
   assertx.is_instance_of("engine.ecs.EntityManager", entity_manager)
   assertx.is_userdata(sprite_atlas)

   self._rendering_config = rendering_config
   self._world_config = world_config
   self._entity_manager = entity_manager

   self._window_width = rendering_config.window.width
   self._window_height = rendering_config.window.height
   self._tile_size = rendering_config.tiles.size
   self._tileset_draw_rounding = 1 / self._tile_size

   -- Canvas is used so that everything can be rendered 1x and then scaled up
   self._canvas = love.graphics.newCanvas(self._window_width * self._tile_size, self._window_height * self._tile_size)
   self._canvas:setFilter("nearest", "nearest")

   self._sprite_batch = love.graphics.newSpriteBatch(sprite_atlas, self._window_width * self._window_height, "stream")
   self._sprite_matrix = nil
   self._opaque_matrix = nil
   self._entity_ids_by_sprite_c = {}
end)

function SpriteRenderer:_create_sprite_layers(matrix_iterator)
   local layer_ids = {}
   local layers_by_id = {}

   for point, layer in matrix_iterator do
      for _, sprite_c in pairs(layer) do
         if not layers_by_id[sprite_c.layer] then
            layers_by_id[sprite_c.layer] = ds.Matrix()
            table.insert(layer_ids, sprite_c.layer)
         end

         layers_by_id[sprite_c.layer]:set(point, sprite_c)
      end
   end

   return layer_ids, layers_by_id
end

function SpriteRenderer:_create_illuminabilities(sprite_matrix_iterator)
   local illuminabilities = ds.Matrix()
   local opaque_matrix = self._opaque_matrix

   for point in sprite_matrix_iterator do
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

function SpriteRenderer:_update_sprite_matrix()
   local matrix = ds.Matrix()

   for _, sprite_c, position_c in self._entity_manager:iterate("sprite", "position") do
      local updated_layer = matrix:get(position_c.point)
      if not updated_layer then
         updated_layer = {}
         matrix:set(position_c.point, updated_layer)
      end
      updated_layer[sprite_c.layer] = sprite_c
   end

   self._sprite_matrix = matrix
end

function SpriteRenderer:_update_opaque_matrix()
   local matrix = ds.Matrix()

   for _, _, position_c in self._entity_manager:iterate("opaque", "position") do
      matrix:set(position_c.point, (matrix:get(position_c.point) or 0) + 1)
   end

   self._opaque_matrix = matrix
end

function SpriteRenderer:_update_entity_ids_by_sprite_c()
   for entity_id, sprite_c in self._entity_manager:iterate("sprite") do
      self._entity_ids_by_sprite_c[sprite_c] = entity_id
   end
end

function SpriteRenderer:render()
   local entity_manager = self._entity_manager

   local camera_point =
      entity_manager:get_component(entity_manager:get_unique_component("camera"), "position")
         .point

   self:_update_sprite_matrix()
   self:_update_opaque_matrix()
   self:_update_entity_ids_by_sprite_c()

   local visible_sprite_matrix_iterator =
      self._sprite_matrix:submatrix_pairs(
         camera_point.x - (self._window_width / 2) - 1,
         camera_point.y - (self._window_height / 2) - 1,
         camera_point.x + (self._window_width / 2),
         camera_point.y + (self._window_height / 2)
      )
   local layer_ids, layers_by_id =
      self:_create_sprite_layers(visible_sprite_matrix_iterator)
   table.sort(layer_ids)

   visible_sprite_matrix_iterator =
      self._sprite_matrix:submatrix_pairs(
         camera_point.x - (self._window_width / 2) - 1,
         camera_point.y - (self._window_height / 2) - 1,
         camera_point.x + (self._window_width / 2),
         camera_point.y + (self._window_height / 2)
      )
   local illuminabilities =
      self:_create_illuminabilities(visible_sprite_matrix_iterator)

   local calculate_alpha =
      create_calculate_alpha(self._world_config.lighting, illuminabilities, camera_point)

   love.graphics.setCanvas(self._canvas)

   -- The background has to be rendered here so that the alphas
   -- go nicely on top of it
   love.graphics.clear(self._world_config.background_color)

   for _, layer_id in ipairs(layer_ids) do
      local sprite_cs = layers_by_id[layer_id]

      self._sprite_batch:clear()
      for point, sprite_c in sprite_cs:pairs() do
         local alpha = calculate_alpha(point)

         local entity_id = self._entity_ids_by_sprite_c[sprite_c]
         if entity_manager:has_component(entity_id, "fog_of_war") then
            local fow_c = entity_manager:get_component(entity_id, "fog_of_war")
            if fow_c.explored and alpha < self._world_config.lighting.explored_alpha then
               alpha = self._world_config.lighting.explored_alpha
            elseif alpha > 0 and not fow_c.explored then
               entity_manager:update_component(entity_id, "fog_of_war", { explored = true })
            end
         end

         if alpha > 0 then
            local offset_x =
               mathx.round(
                  point.x - camera_point.x + (self._window_width / 2),
                  self._tileset_draw_rounding
               )
            local offset_y =
               mathx.round(
                  point.y - camera_point.y + (self._window_height / 2),
                  self._tileset_draw_rounding
               )

            self._sprite_batch:setColor(1, 1, 1, alpha)
            self._sprite_batch:add(
               sprite_c.quad,
               offset_x * self._tile_size,
               offset_y * self._tile_size
            )
         end
      end
      self._sprite_batch:flush()

      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(self._sprite_batch)
   end

   love.graphics.setCanvas()
   love.graphics.draw(self._canvas, 0, 0, 0, self._rendering_config.tiles.scale)
end

return SpriteRenderer