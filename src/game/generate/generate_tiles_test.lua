local EntityManager = require("src.engine.ecs.entity_manager")
local components = require("src.game.components")
local generate_tiles = require("src.game.generate.generate_tiles")

local level_config = {
   width = 8,
   height = 8,

   monsters = false,

   lighting = false,

   tiles = {
      algorithm = "cellular_automatons",

      initial_wall_chance = 0.45,
      iterations = 8,
      birth_threshold = 5,
      survival_threshold = 4,
   },
}

do
   local em = EntityManager(tablex.keys(components))
   generate_tiles(em, level_config)
   local position_component_n = 0
   for _ in em:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end

