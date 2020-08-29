local EntityManager = require("src.engine.ecs.entity_manager")
local components = require("src.game.components")
local generate_tiles = require("src.game.generate.generate_tiles")
local load_sprite_atlas = require("src.game.sprites.load_sprite_atlas")

local world_config = {
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

local _, sprite_quads = load_sprite_atlas(1)

do
   local entity_manager = EntityManager(components)
   generate_tiles(world_config, entity_manager, components, sprite_quads)
   local position_component_n = 0
   for _ in entity_manager:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end

