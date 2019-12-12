local create_tileset = require("game.render.create_tileset")

do
   local tileset = create_tileset(16)
   assert(type(tileset) == "table")
end

do
   local _, err = pcall(function()
      create_tileset(0)
   end)
   assert(err ~= nil)
end
