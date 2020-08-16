require("./init")

local devtools = require("src.lib.devtools")
local parse_args = require("src.lib.parse_args")
local seed = require("src.lib.seed")

local EntityManager = require("src.engine.ecs.entity_manager")
local PlayerInput = require("src.engine.input.player_input")
local Renderer = require("src.engine.rendering.renderer")
local validate_config = require("src.engine.config.validate_config")

local Systems = require("src.game.systems")
local components = require("src.game.components")
local create_tileset = require("src.game.tileset.create_tileset")
local generate = require("src.game.generate")

local config = require("config")
validate_config(config)

local game_status
local systems
local renderer
local player_input

local function reset()
   seed()

   local entity_manager = EntityManager(tablex.keys(components))

   entity_manager.event_subject:subscribe(
      entity_manager.event_subject.events.entity_to_be_removed,
      function(event_data)
         if event_data.entity.player then
            game_status = "resetting"
            reset()
         end
      end
   )

   player_input = PlayerInput(config.player_input)

   player_input.event_subject:subscribe("quit_game", function()
      game_status = "terminating"
   end)
   player_input.event_subject:subscribe("toggle_game_pause", function()
      game_status = game_status ~= "paused" and "paused" or "running"
   end)

   systems = {
      Systems.ChaseSystem(config.level, entity_manager),
      Systems.AttackSystem(config.level, entity_manager),
      Systems.DeathSystem(config.level, entity_manager),
      Systems.MovementSystem(config.level, entity_manager, player_input),
      Systems.MonsterSpawningSystem(config.level, entity_manager),
   }

   local tileset = create_tileset(config.rendering.tiles.size)
   renderer = Renderer(config.rendering, config.level, entity_manager, tileset)

   generate(entity_manager, config.level)

   game_status = "running"
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
   if game_status == "terminating" then
      love.event.quit()
   end
   if game_status == "resetting" then
      reset()
   end
   if game_status == "paused" then
      return
   end

   player_input:tick(dt)

   for _, system in ipairs(systems) do
      system:run()
   end

   devtools.tick()
end

function love.draw()
   if game_status == "resetting" then
      return
   end

   renderer:render()
end
