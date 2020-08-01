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
   entity_manager = nil,
   config = config,
}

local update
local render

local function reset()
   seed()

   local em = EntityManager()
   game_state.entity_manager = em

   update = make_update(game_state, PlayerInput(config.player_input))
   render = make_render(config.rendering, game_state)

   generate(em, config.level)

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

   update(dt)

   devtools.tick()
end

function love.draw()
   if game_state.status == "resetting" then
      return
   end

   render()
end
