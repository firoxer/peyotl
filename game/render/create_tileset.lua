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
         [tileset_quad_names.dungeon_wall] = quad(0, 0),
         [tileset_quad_names.dungeon_wall_south] = quad(0, 1),
         [tileset_quad_names.dungeon_player] = quad(1, 0),
         [tileset_quad_names.dungeon_monster] = quad(1, 1),
         [tileset_quad_names.dungeon_empty] = quad(2, 0),
         [tileset_quad_names.dungeon_empty2] = quad(2, 1),
         [tileset_quad_names.dungeon_gem1] = quad(3, 0),
         [tileset_quad_names.dungeon_gem2] = quad(3, 1),

         [tileset_quad_names.temple_wall] = quad(4, 0),
         [tileset_quad_names.temple_wall_south] = quad(4, 1),
         [tileset_quad_names.temple_player] = quad(5, 0),
         [tileset_quad_names.temple_monster] = quad(5, 1),
         [tileset_quad_names.temple_empty] = quad(6, 0),
         [tileset_quad_names.temple_empty2] = quad(6, 1),
         [tileset_quad_names.temple_altar] = quad(7, 0),
      }),
   }
end
