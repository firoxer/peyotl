local tile_names = require("src.game.tileset.tile_names")

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
         [tile_names.wall] = quad(0, 0),
         [tile_names.wall_south] = quad(0, 1),
         [tile_names.player] = quad(1, 0),
         [tile_names.monster] = quad(1, 1),
         [tile_names.empty] = quad(2, 0),
         [tile_names.empty2] = quad(2, 1),
         [tile_names.gem1] = quad(3, 0),
         [tile_names.gem2] = quad(3, 1),
      }),
   }
end
