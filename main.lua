require("./init")

local config = require("config")
local devtools = require("devtools")
local parse_args = require("parse_args")
local seed = require("seed")

local EntityManager = require("game.entity.entity_manager")
local PlayerInput = require("game.player_input")
local generate = require("game.entity.generate")
local make_render = require("game.make_render")
local make_update = require("game.make_update")

local game_state = {
   status = "running",
   current_level = config.initial_player_level,
   levels = {}
}

local update
local render

local function reset()
   seed()

   game_state.levels = tablex.mappairs(config.levels, function(_, level_config)
      local em = EntityManager()

      em:register_entity_id(em:new_entity_id(), "player")
      em:register_entity_id(em:new_entity_id(), "altar_1")
      em:register_entity_id(em:new_entity_id(), "altar_2")
      em:register_entity_id(em:new_entity_id(), "altar_3")
      em:register_entity_id(em:new_entity_id(), "altar_4")

      return {
         config = level_config,
         entity_manager = em,
      }
   end)

   update = make_update(game_state, PlayerInput(config.player_input))
   render = make_render(config.rendering, game_state)

   -- Generation has to happen after updating and rendering are ready because
   -- they listen to levels' entity managers that emit events during generation
   for level_name, level in pairs(game_state.levels) do
      generate(level.entity_manager, level_name, level.config)
   end

   game_state.status = "running"
end

function love.load(args)
   local tile_size = config.rendering.tiles.size
   local tile_scale = config.rendering.tiles.scale
   love.window.setMode(
      config.rendering.window.width * tile_size * tile_scale,
      config.rendering.window.height * tile_size * tile_scale,
      { vsync = config.rendering.enable_vsync }
   )

   parse_args(args)
   reset()
end

local level_at_last_update = game_state.current_level
function love.update(dt)
   if game_state.status == "terminating" then
      love.event.quit()
   end
   if game_state.status == "resetting" then
      reset()
   end
   if game_state.status == "paused" then
      return
   end

   if level_at_last_update ~= game_state.current_level and game_state.current_level == "dungeon" then
      generate(game_state.levels.dungeon.entity_manager, "dungeon", game_state.levels.dungeon.config)
   end
   level_at_last_update = game_state.current_level

   update(dt)

   devtools.tick()
end

function love.draw()
   if game_state.status == "resetting" then
      return
   end

   render()
end
