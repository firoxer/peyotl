local tileset_quad_names = require("game.render.tileset_quad_names")

return function(rendering_config)
   local cell = rendering_config.tileset_cell_size

   local image = love.graphics.newImage("data/tileset.png")
   image:setFilter("nearest", "linear")

   local tileset_image_width = image:getWidth()
   local tileset_image_height = image:getHeight()
   local quad = function(x, y)
      return love.graphics.newQuad(cell * x, cell * y, cell, cell, tileset_image_width, tileset_image_height)
   end

   return {
      image = image,
      quads = table.uptight({
         [tileset_quad_names.underground_player] = quad(0, 0),
         [tileset_quad_names.underground_monster] = quad(1, 0),

         [tileset_quad_names.underground_wall] = quad(2, 0),
         [tileset_quad_names.underground_empty] = quad(2, 2),
         [tileset_quad_names.underground_empty2] = quad(2, 1),

         [tileset_quad_names.aboveground_player] = quad(3, 0),
         [tileset_quad_names.aboveground_monster] = quad(4, 0),

         [tileset_quad_names.aboveground_wall] = quad(5, 0),
         [tileset_quad_names.aboveground_empty] = quad(5, 2),
         [tileset_quad_names.aboveground_empty2] = quad(5, 1),
      }),
   }
end
