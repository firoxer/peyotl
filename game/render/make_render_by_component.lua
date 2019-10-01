--- Technically this should go under systems/ but this way it just makes more sense
local round = math.round

local Matrix = require("game.data_structures.matrix")
local component_names = require("game.entity.component_names")
local create_calculate_alpha = require("game.render.create_calculate_alpha")
local make_render_background = require("game.render.make_render_background")

return function(rendering_config, levels_config, entity_manager, tileset)
   local camera_rigidness = rendering_config.camera_rigidness
   local window_width = rendering_config.window_width
   local window_height = rendering_config.window_height
   local scale = rendering_config.scale
   local tile_size = rendering_config.tile_size
   local tileset_draw_rounding = 1 / tile_size

   local current_camera_x = 0
   local current_camera_y = 0

   local is_out_of_view = function(render_pos_c)
      return render_pos_c.point.x < current_camera_x - (window_width / 2) - 1
         or render_pos_c.point.x > current_camera_x + (window_width / 2)
         or render_pos_c.point.y < current_camera_y - (window_height / 2) - 1
         or render_pos_c.point.y > current_camera_y + (window_height / 2)
   end

   -- Canvas is used so that everything can be rendered 1x and then scaled up
   local canvas = love.graphics.newCanvas(window_width * tile_size, window_height * tile_size)
   canvas:setFilter("nearest", "nearest")

   local render_background = make_render_background(levels_config, entity_manager)

   local tileset_batch = love.graphics.newSpriteBatch(tileset.image, window_width * window_height)

   return function()
      local camera_entity_position_c = entity_manager:get_component(
         entity_manager:get_unique_component(component_names.camera),
         component_names.position
      )

      -- By moving the camera only a bit at a time, it gets nice and sticky
      -- and it follows its target more naturally
      local camera_entity_position_point = camera_entity_position_c.point
      current_camera_x = current_camera_x + (camera_entity_position_point.x - current_camera_x) * camera_rigidness
      current_camera_y = current_camera_y + (camera_entity_position_point.y - current_camera_y) * camera_rigidness

      local renderables_by_layer = {}
      local renderable_layer_ids = {}
      local illuminabilities = Matrix.new()
      -- TODO: Keep track of render_c's per position in a matrix and iterate its submatrix
      -- instead of going to the entity manager every frame
      for id, render_c, position_c in entity_manager:iterate(component_names.render, component_names.position) do
         if position_c.level ~= camera_entity_position_c.level or is_out_of_view(position_c) then
            goto continue
         end

         if not renderables_by_layer[render_c.layer] then
            renderables_by_layer[render_c.layer] = Matrix.new()
            table.insert(renderable_layer_ids, render_c.layer)
         end

         renderables_by_layer[render_c.layer]:set(position_c.point, render_c)

         if entity_manager:get_component(id, component_names.opaque) == nil then
            illuminabilities:set(position_c.point, true)
         else
            illuminabilities:set(position_c.point, false)
         end

         ::continue::
      end

      for point in illuminabilities:pairs() do
         local has_illuminable_neighbor = false
         for neighbor_point in pairs(illuminabilities:get_immediate_neighbors(point, true)) do
            if illuminabilities:get(neighbor_point) == true then
               has_illuminable_neighbor = true
            end
         end

         if not has_illuminable_neighbor then
            illuminabilities:remove(point)
         end
      end

      local level_config = levels_config[camera_entity_position_c.level]
      local calculate_alpha =
         create_calculate_alpha(level_config, illuminabilities, camera_entity_position_c)

      love.graphics.setCanvas(canvas)
      love.graphics.clear()

      -- The background has to be rendered here so that the alphas
      -- go nicely on top of it
      render_background()

      table.sort(renderable_layer_ids)
      for _, layer_id in ipairs(renderable_layer_ids) do
         local renderables = renderables_by_layer[layer_id]

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
      love.graphics.draw(canvas, 0, 0, 0, scale)
   end
end
