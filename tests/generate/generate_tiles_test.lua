local EntityManager = require("game.entity.entity_manager")
local generate_tiles = require("game.generate.generate_tiles")

local config = {
   level_1 = {
      width = 8,
      height = 8,

      monsters = false,

      generation = {
         algorithm = "cellular_automatons",

         initial_wall_chance = 0.45,
         iterations = 8,
         birth_threshold = 5,
         survival_threshold = 4,
      },
   },

   level_2 = {
      width = 32,
      height = 32,

      monsters = false,

      generation = {
         algorithm = "preset_temple",

         square_size_min = 2,
         square_size_max = 15,
         minimum_wall_density = 0.3,
      },
   }
}

do
   local em = EntityManager.new()
   generate_tiles(em, config)
   local position_component_n = 0
   for _ in em:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end

