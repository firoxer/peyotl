local generate_altars = require("game.entity.generate.generate_altars")
local generate_gems = require("game.entity.generate.generate_gems")
local generate_player = require("game.entity.generate.generate_player")
local generate_tiles = require("game.entity.generate.generate_tiles")

local EntityGenerator = {}

function EntityGenerator:_generate_tiles(levels_config)
   levels_config = levels_config or self._config.levels

   self._tile_ids = generate_tiles(self._entity_manager, levels_config)
end

function EntityGenerator:_generate_player()
   self._player_id = generate_player(self._entity_manager, self._config.player)

--[[
   -- TODO: Optimize
   self._entity_manager.subject:subscribe_to_any_change_of(
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

function EntityGenerator:_generate_gems()
   generate_gems(self._entity_manager, self._config.levels)
end

function EntityGenerator:_generate_altars()
   generate_altars(self._entity_manager, self._config.levels)
end

function EntityGenerator:generate()
   self:_generate_tiles()
   self:_generate_player()
   self:_generate_gems()
   self:_generate_altars()
end

local create_object = prototypify(EntityGenerator)
return {
   new = function(entity_manager, config)
      return create_object({
         _entity_manager = entity_manager,
         _config = config,

         _player_id = nil,
         _tile_ids = {},
      })
   end
}
