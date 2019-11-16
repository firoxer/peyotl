local tileset_quad_names = require("game.render.tileset_quad_names")

return function(rendering_config)
   local tile_size = rendering_config.tile_size

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
      quads = table.uptight({
         [tileset_quad_names.player] = quad(0, 0),
         [tileset_quad_names.monster] = quad(1, 0),

         [tileset_quad_names.gem1] = quad(2, 0),
         [tileset_quad_names.gem2] = quad(3, 0),

         [tileset_quad_names.dungeon_wall] = quad(4, 0),
         [tileset_quad_names.dungeon_empty] = quad(4, 2),
         [tileset_quad_names.dungeon_empty2] = quad(4, 1),

         [tileset_quad_names.temple_wall] = quad(5, 0),
         [tileset_quad_names.temple_empty] = quad(5, 2),
         [tileset_quad_names.temple_empty2] = quad(5, 1),
      }),
   }
end
