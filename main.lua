require("./init")

local Profiler = require("src.engine.debug.profiler")
local MemoryUsageReporter = require("src.engine.debug.memory_usage_reporter")
local retard_performance = require("src.engine.debug.retard_performance")
local EntityManager = require("src.engine.ecs.entity_manager")
local PauseScreenRenderer = require("src.engine.rendering.pause_screen_renderer")
local PlayerInput = require("src.engine.input.player_input")
local SpriteRenderer = require("src.engine.rendering.sprite_renderer")
local validate_config = require("src.engine.config.validate_config")

local ArgParser = require("src.util.arg_parser")
local Systems = require("src.game.systems")
local components = require("src.game.components")
local load_sprite_atlas = require("src.game.sprites.load_sprite_atlas")
local generate = require("src.game.generate")

local config = require("config")
validate_config(config)

local seed = 1
local game_paused = false
local systems
local renderer
local pause_screen_renderer
local player_input
local ticks = {}

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

   local sprite_atlas, sprite_quads = load_sprite_atlas(config.rendering.tiles.size)

   systems = {
      Systems.Chase(config.world, entity_manager),
      Systems.Attack(config.world, entity_manager),
      Systems.Death(config.world, entity_manager),
      Systems.Movement(config.world, entity_manager, player_input),
      Systems.MonsterSpawning(config.world, entity_manager, components, sprite_quads),
   }

   entity_manager.event_subject:subscribe(
      entity_manager.event_subject.events.entity_to_be_removed,
      function(event_data)
         if event_data.entity.player then
            reset()
         end
      end
   )

   renderer = SpriteRenderer(config.rendering, config.world, entity_manager, sprite_atlas)

   pause_screen_renderer = PauseScreenRenderer(config.rendering)

   generate(config.world, entity_manager, components, sprite_quads)

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

   local arg_parser
   arg_parser = ArgParser({
      ["--disable-vsync"] = function()
         config.rendering.enable_vsync = false
         log.debug("disabled vsync")
      end,

      ["--god-mode"] = function()
         config.world.player.initial_health = math.huge
         log.debug("enabled god mode")
      end,

      ["--profile"] = function()
         table.insert(ticks, tablex.bind(Profiler(), "tick"))
         log.debug("enabled profiling")
      end,

      ["--report-memory-usage"] = function()
         table.insert(ticks, tablex.bind(MemoryUsageReporter(), "tick"))
         log.debug("enabled memory usage reports")
      end,

      ["--retard-performance"] = function()
         table.insert(ticks, retard_performance)
         log.debug("enabled performance retardation")
      end,

      ["--show-fps"] = function()
         config.rendering.fps_overlay_enabled = true
         log.debug("enabled FPS overlay")
      end,

      ["--development"] = function()
         arg_parser:trigger_reaction("--retard-performance")
         arg_parser:trigger_reaction("--show-fps")
      end,
   })

   arg_parser:parse(args)

   reset()
end

function love.update(dt)
   player_input:tick(dt)

   if game_paused then
      return
   end

   for _, tick in ipairs(ticks) do
      tick()
   end

   for _, system in ipairs(systems) do
      system:run()
   end
end

function love.draw()
   if game_paused then
      pause_screen_renderer:render()
   else
      renderer:render()
   end
end
