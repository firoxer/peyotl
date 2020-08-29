local EntityManager = require("src.engine.ecs.entity_manager")
local components = require("src.game.components")
local generate_player = require("src.game.generate.generate_player")
local load_sprite_atlas = require("src.game.sprites.load_sprite_atlas")

local player_config = {
   initial_health = 123,
   max_health = 123,
}

local _, sprite_quads = load_sprite_atlas(1)

do
   local entity_manager = EntityManager(components)

   -- Tile for the player to spawn on
   local tile_id = entity_manager:new_entity_id()
   entity_manager:add_component(tile_id, components.Position(ds.Point.get(1, 1)))

   generate_player(player_config, entity_manager, components, sprite_quads)

   local player_id = entity_manager:get_unique_component("player")

   assert(entity_manager:get_component(player_id, "health").amount == player_config.initial_health)
   assert(entity_manager:get_unique_component("input") ~= nil)
end

