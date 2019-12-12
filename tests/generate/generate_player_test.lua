local EntityManager = require("game.entity.entity_manager")
local create_component = require("game.entity.create_component")
local generate_player = require("game.generate.generate_player")

local player_config = {
   initial_level = "temple",
   initial_health = 123,
   max_health = 123,
}

do
   local em = EntityManager.new()

   local player_id = em:new_entity_id()

   em:register_entity_id(player_id, "player")

   -- Tile for the player to spawn on
   local tile_id = em:new_entity_id()
   em:add_component(tile_id, create_component.position("temple", ds.Point.new(1, 1)))

   generate_player(em, player_config)

   assert(em:get_component(player_id, "health").amount == player_config.initial_health)
   assert(em:get_unique_component("input") ~= nil)
end

