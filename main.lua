require("./init")

local devtools = require("src.lib.devtools")
local parse_args = require("src.lib.parse_args")

local EntityManager = require("src.engine.ecs.entity_manager")
local PauseScreenRenderer = require("src.engine.rendering.pause_screen_renderer")
local PlayerInput = require("src.engine.input.player_input")
local Renderer = require("src.engine.rendering.renderer")
local validate_config = require("src.engine.config.validate_config")

local components = require("src.game.components")
local Systems = require("src.game.systems")
local create_tileset = require("src.game.tileset.create_tileset")
local generate = require("src.game.generate")

local config = require("config")
validate_config(config)

local seed = 1
local game_paused = false
local systems
local renderer
local pause_screen_renderer
local player_input

local function reseed()
   if not seed then
      math.randomseed(os.time())
      seed = math.random() * ((2^51) - 1)
   end

   seed = seed + 1
   math.randomseed(seed)
   love.math.setRandomSeed(seed)
end

local function reset()
   reseed()

   player_input = PlayerInput(config.player_input)

   player_input.event_subject:subscribe("quit_game", function()
      love.event.quit()
   end)
   player_input.event_subject:subscribe("toggle_game_pause", function()
      game_paused = not game_paused
   end)

   local entity_manager = EntityManager(components)

   systems = {
      Systems.Chase(config.world, entity_manager),
      Systems.Attack(config.world, entity_manager),
      Systems.Death(config.world, entity_manager),
      Systems.Movement(config.world, entity_manager, player_input),
      Systems.MonsterSpawning(config.world, entity_manager, components),
   }

   entity_manager.event_subject:subscribe(
      entity_manager.event_subject.events.entity_to_be_removed,
      function(event_data)
         if event_data.entity.player then
            reset()
         end
      end
   )

   local tileset = create_tileset(config.rendering.tiles.size)
   renderer = Renderer(config.rendering, config.world, entity_manager, tileset)

   pause_screen_renderer = PauseScreenRenderer(config.rendering)

   generate(config.world, entity_manager, components)

   game_paused = false
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
   player_input:tick(dt)

   if game_paused then
      return
   end

   for _, system in ipairs(systems) do
      system:run()
   end

   devtools.tick()
end

function love.draw()
   if game_paused then
      pause_screen_renderer:render()
   else
      renderer:render()
   end
end
