local EntityManager = require("src.engine.ecs.entity_manager")
local components = require("src.game.components")
local generate_player = require("src.game.generate.generate_player")

local player_config = {
   initial_health = 123,
   max_health = 123,
}

do
   local em = EntityManager(tablex.keys(components))

   -- Tile for the player to spawn on
   local tile_id = em:new_entity_id()
   em:add_component(tile_id, components.position(ds.Point.get(1, 1)))

   generate_player(em, player_config)

   local player_id = em:get_unique_component("player")

   assert(em:get_component(player_id, "health").amount == player_config.initial_health)
   assert(em:get_unique_component("input") ~= nil)
end

