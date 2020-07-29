local tileset_quad_names = require("game.render.tileset_quad_names")

return function(tile_size)
   assertx.is_true(tile_size >= 1)

   local image = love.graphics.newImage("data/tileset.png")
   image:setFilter("nearest", "linear")

   local tileset_image_width = image:getWidth()
   local tileset_image_height = image:getHeight()
   local quad = function(x, y)
      return love.graphics.newQuad(
         tile_size * x,
         tile_size * y,
         tile_size,
         tile_size,
         tileset_image_width,
         tileset_image_height
      )
   end

   return {
      image = image,
      quads = tablex.uptight({
         [tileset_quad_names.wall] = quad(0, 0),
         [tileset_quad_names.wall_south] = quad(0, 1),
         [tileset_quad_names.player] = quad(1, 0),
         [tileset_quad_names.monster] = quad(1, 1),
         [tileset_quad_names.empty] = quad(2, 0),
         [tileset_quad_names.empty2] = quad(2, 1),
         [tileset_quad_names.gem1] = quad(3, 0),
         [tileset_quad_names.gem2] = quad(3, 1),
      }),
   }
end
