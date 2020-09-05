local shader = love.graphics.newShader([[
   uniform Image visibility_map;
   uniform float x_tiles_n;
   uniform float y_tiles_n;
   uniform float tile_size;
   uniform float penetration;
   uniform float max_range;

   float bresenham(vec2 a, vec2 b, float resolution)
   {
      float step = 1 / tile_size / max(x_tiles_n, y_tiles_n) * resolution;
      float real_tile_size = 1 / max(x_tiles_n, y_tiles_n);
      float real_max_range = real_tile_size * max_range;

      a.x = floor(a.x / step + (step / 2)) * step;
      a.y = floor(a.y / step + (step / 2)) * step;
      b.x = floor(b.x / step + (step / 2)) * step;
      b.y = floor(b.y / step + (step / 2)) * step;

      float dx = abs(b.x - a.x);
      float dy = abs(b.y - a.y);
      float err = dx - dy;

      float sx = (a.x < b.x) ? step : -step;
      float sy = (a.y < b.y) ? step : -step;

      float x = a.x;
      float y = a.y;
      float cur_penetration = penetration;
      while (true) {
         float rounded_x = floor(x / real_tile_size) * real_tile_size;
         float rounded_y = floor(y / real_tile_size) * real_tile_size;

         float visibility = Texel(visibility_map, (vec2(rounded_x, rounded_y))).a;
         if (visibility == 0.0) {
            --cur_penetration;
         }

         float cur_dx = abs(b.x - x);
         float cur_dy = abs(b.y - y);
         if (cur_dx * cur_dx + cur_dy * cur_dy > real_max_range * real_max_range) { // Fast Euclidean distance comparison
            --cur_penetration;
         }

         if (cur_penetration <= 0) {
            return 0.0;
         }

         if (abs(x - b.x) < step && abs(y - b.y) < step) {
            return cur_penetration / penetration;
         }

         float e2 = 2 * err;

         if (e2 > -dy) {
            err -= dy;
            x += sx;
         }

         if (e2 < dx) {
            err += dx;
            y += sy;
         }
      }
   }

   vec4 effect(vec4 _color, Image texture, vec2 texture_coords, vec2 screen_coords)
   {
      vec4 pixel = Texel(texture, texture_coords);

      vec2 center = vec2(0.5, 0.5);

      float resolution = 16;
      float alpha = bresenham(center, texture_coords, resolution);

      return vec4(pixel.rgb, alpha);
   }
]])

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

function SpriteRenderer:_create_visibility_map(camera_point)
   local nw_bound = ds.Point.get(
      math.ceil(camera_point.x - (self._window_width / 2)),
      math.ceil(camera_point.y - (self._window_height / 2))
   )

   local visibility_map = love.image.newImageData(self._window_width, self._window_height)

   local opaque_matrix = self._opaque_matrix
   love.graphics.setColor(1, 1, 1, 1)
   visibility_map:mapPixel(function(x, y)
      local relative_point = ds.Point.offset(nw_bound, x, y)

      if opaque_matrix:has(relative_point) then
         return 0, 0, 0, 0
      end

      return 1, 1, 1 ,1
   end)

   return love.graphics.newImage(visibility_map)
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
         camera_point.x - (self._window_width / 2),
         camera_point.y - (self._window_height / 2),
         camera_point.x + (self._window_width / 2),
         camera_point.y + (self._window_height / 2)
      )
   local layer_ids, layers_by_id =
      self:_create_sprite_layers(visible_sprite_matrix_iterator)
   table.sort(layer_ids)

   local visibility_map = self:_create_visibility_map(camera_point)
   visibility_map:setFilter("nearest", "nearest")

   love.graphics.setCanvas(self._canvas)

   -- The background has to be rendered here so that the alphas
   -- go nicely on top of it
   love.graphics.clear(self._world_config.background_color)

   for _, layer_id in ipairs(layer_ids) do
      local sprite_cs = layers_by_id[layer_id]

      self._sprite_batch:clear()
      for point, sprite_c in sprite_cs:pairs() do
         local alpha = 1 -- calculate_alpha(point)

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
                  point.x - camera_point.x + (self._window_width / 2) - 0.5,
                  self._tileset_draw_rounding
               )
            local offset_y =
               mathx.round(
                  point.y - camera_point.y + (self._window_height / 2) - 0.5,
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

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setCanvas()
   love.graphics.setShader(shader)
   shader:send("visibility_map", visibility_map)
   shader:send("x_tiles_n", self._rendering_config.window.width)
   shader:send("y_tiles_n", self._rendering_config.window.height)
   shader:send("tile_size", self._rendering_config.tiles.size)
   shader:send("max_range", 5.8)
   shader:send("penetration", 2)
   love.graphics.draw(self._canvas, 0, 0, 0, self._rendering_config.tiles.scale)
   love.graphics.setShader()
end

return SpriteRenderer