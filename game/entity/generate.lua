local generate_altars = require("game.entity.generate.generate_altars")
local generate_gems = require("game.entity.generate.generate_gems")
local generate_player = require("game.entity.generate.generate_player")
local generate_tiles = require("game.entity.generate.generate_tiles")

return function(em, level_name, level_config)
   em:flush()

   generate_tiles(em, level_name, level_config)
   generate_player(em, level_config)
   generate_gems(em, level_config)
   generate_altars(em, level_config)

--[[
   -- TODO: Optimize
   em.subject:subscribe_to_any_change_of(
      { "position" },
      function(event_data)
         if event_data.entity_id ~= self._player_id then
            return
         end

         if event_data.updated_fields == nil or event_data.updated_fields.level == nil then
            return
         end

         local updated_level = event_data.updated_fields.level
         if not self._config.levels[updated_level].generation.regenerate_on_player_warp then
            return
         end

         self:_generate_tiles(updated_level, { self._config.levels[updated_level] })
      end
   )
--]]
end
