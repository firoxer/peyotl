--local tile_kinds = require("game.generate.tiles.kinds")

return function(level_config)
   if level_config.width ~= 64 or level_config.height ~= 64 then
      error("staircase_maze generation works only a 64 tile high level")
   end

   --local algo = level_config.generation_algorithm_settings

   local matrix = ds.Matrix.new()

   return matrix
end

