local config = require("config")

local EntityManager = require("game.entity.entity_manager")
local generate = require("game.generate")

do
   local em = EntityManager.new()
   generate(em, config)
   local position_component_n = 0
   for _ in em:iterate("position") do
      position_component_n = position_component_n + 1
   end

   assert(position_component_n >= 1)
end
