--- Technically this should go under systems/ but this way it just makes more sense

local Matrix = require("game.data_structures.matrix")
local Point = require("game.data_structures.point")
local VisibilityCalculator = require("game.render.visibility_calculator")
local component_names = require("game.entity.component_names")

local function smoothen_alphas(level_config, illuminable, alphas)
   -- I don't know if using the same matrix as both the source and target
   -- of smoothening is a good idea, but hey it seems to work
   local unexplored_alpha = level_config.lighting_settings.unexplored_alpha
   for point, alpha in alphas:ipairs() do
      if alpha <= unexplored_alpha then
         local max_neighbor_alpha = unexplored_alpha
         for neighbor_point, neighbor_alpha in pairs(alphas:get_immediate_neighbors(point, true)) do
            if neighbor_alpha > max_neighbor_alpha and illuminable:get(neighbor_point) then
               max_neighbor_alpha = neighbor_alpha
            end
         end
         alphas:set(point, max_neighbor_alpha * 0.5)
      else
         alphas:set(point, alpha)
      end
   end
end

return function(rendering_config, levels_config, entity_manager, tileset)
   local window_width = rendering_config.window_width
   local window_height = rendering_config.window_height
   local window_cell_size = rendering_config.window_cell_size

   local offset_point = function(a, b)
      return Point.new(
         a.x - b.x + math.floor(window_width / 2),
         a.y - b.y + math.floor(window_height / 2)
      )
   end

   local is_out_of_view = function(camera_pos_c, render_pos_c)
      return render_pos_c.level ~= camera_pos_c.level
         or render_pos_c.point.x < camera_pos_c.point.x - (window_width / 2)
         or render_pos_c.point.x >= camera_pos_c.point.x + (window_width / 2)
         or render_pos_c.point.y < camera_pos_c.point.y - (window_height / 2)
         or render_pos_c.point.y >= camera_pos_c.point.y + (window_height / 2)
   end

   local tileset_batch = love.graphics.newSpriteBatch(tileset.image, window_width * window_height)
   while true do
      coroutine.yield()

      local camera_entity_id = entity_manager:get_unique_component(component_names.camera)
      local camera_entity_position_c = entity_manager:get_component(camera_entity_id, component_names.position)

      local renderable = Matrix.new()
      local illuminable = Matrix.new()
      for id, render_c, position_c in entity_manager:iterate(component_names.render, component_names.position) do
         if is_out_of_view(camera_entity_position_c, position_c) then
            goto continue
         end

         local offset_position = offset_point(position_c.point, camera_entity_position_c.point)
         if not renderable:has(offset_position)
            or renderable:get(offset_position).layer <= render_c.layer
         then
            renderable:set(offset_position, render_c)
         end

         if entity_manager:get_component(id, component_names.opaque) == nil then
            illuminable:set(offset_position, true)
         else
            illuminable:set(offset_position, false)
         end

         ::continue::
      end

      local level_config = levels_config[camera_entity_position_c.level]
      local calculate_alpha
      if level_config.lighting == "full" then
         calculate_alpha = function()
            return 1
         end
      elseif level_config.lighting == "fog_of_war" then
         local visibility_calculator = VisibilityCalculator.new(
            function(point)
               return illuminable:get(point)
            end,
            level_config.lighting_settings.lighting_max_range,
            level_config.lighting_settings.lighting_dimming_range
         )

         visibility_calculator:set_light_source(
            offset_point(camera_entity_position_c.point, camera_entity_position_c.point)
         )

         local unexplored_alpha = level_config.lighting_settings.unexplored_alpha

         local alpha_matrix = Matrix.new()
         for point in renderable:ipairs() do
            alpha_matrix:set(point, math.max(visibility_calculator:calculate(point), unexplored_alpha))
         end

         smoothen_alphas(level_config, illuminable, alpha_matrix)

         calculate_alpha = function(point)
            return alpha_matrix:get(point)
         end
      end

      tileset_batch:clear()
      for point, render_c in renderable:ipairs() do
         local alpha = calculate_alpha(point)
         if alpha > 0 then
            tileset_batch:setColor(1, 1, 1, alpha)
            tileset_batch:add(
               tileset.quads[render_c.tileset_quad_name],
               point.x * window_cell_size,
               point.y * window_cell_size
            )
         end
      end
      tileset_batch:flush()

      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(tileset_batch)
   end
end
