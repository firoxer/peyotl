return function(tile_size)
   assertx.is_true(tile_size >= 1)

   local image = love.graphics.newImage("src/game/sprites/sprite_atlas.png")
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

   return image, tablex.uptight({
      wall = quad(0, 0),
      wall_south = quad(0, 1),
      empty1 = quad(1, 0),
      empty2 = quad(1, 1),
      player1 = quad(2, 0),
      player2 = quad(2, 1),
      monster1 = quad(3, 0),
      monster2 = quad(3, 1),
      gem1 = quad(4, 0),
      gem2 = quad(4, 1),
   })
end

