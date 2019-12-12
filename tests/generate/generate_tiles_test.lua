local EntityManager = require("game.entity.entity_manager")
local config = require("game.config")
local generate_tiles = require("game.generate.generate_tiles")

do
   local em = EntityManager.new()
   generate_tiles(em, config.levels)
   local position_component_n = 0
   for _ in em:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end

