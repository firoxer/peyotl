require("./init")

local devtools = require("devtools")
local seed = require("seed")

local EntityManager = require("game.entity.entity_manager")
local PlayerInput = require("game.player_input")
local Subject = require("game.event.subject")
local config = require("game.config")
local events = require("game.event.events")
local generate = require("game.generate")
local make_render = require("game.make_render")
local make_update = require("game.make_update")

local function parse_args(raw_args)
   local args = {}
   for _, arg in ipairs(raw_args) do
      args[arg:gsub("^-+", ""):gsub("-", "_")] = true
   end

   if args.h or args.help then
      print([[usage: ./run [options]
    --log-events
    --production
    --profile
    --report-memory-usage
    --report-low-fps
    --retard-performance]])
      love.event.quit()
      return
   end

   if not args.production then
      -- Default flags for development
      args.report_low_fps = true
      args.retard_performance = true
   end

   if args.log_events then
      Subject.enable_event_logging()
      log.debug("enabled event logging")
   end
   if args.profile then
      devtools.enable_profiler_reports()
      log.debug("enabled profiling")
   end
   if args.report_memory_usage then
      devtools.enable_memory_usage_reports()
      log.debug("enabled memory usage reports")
   end
   if args.report_low_fps then
      devtools.enable_low_fps_reports()
      log.debug("enabled low FPS reports")
   end
   if args.retard_performance then
      devtools.enable_performance_retardation()
      log.debug("enabled performance retardation")
   end
end

local game_paused = false
local game_terminating = false
local game_resetting = false

local player_input = PlayerInput.new(config.player_input)

local entity_manager
local player_id

player_input.subject:subscribe(function(event)
   if event == events.quit_game then
      game_terminating = true
   elseif event == events.toggle_game_pause then
      game_paused = not game_paused
   end
end)

local update
local render

local function reset()
   seed()

   entity_manager = EntityManager.new()

   entity_manager.subject:subscribe(function(event, data)
      if event == events.entity_removed and data.entity_id == player_id then
         game_resetting = true
      end
   end)

   update = make_update(config.levels, entity_manager, player_input)
   render = make_render(config.rendering, config.levels, entity_manager)

   local generation_data = generate(entity_manager, config)

   player_id = generation_data.player_id

   game_resetting = false
end

function love.load(args)
   parse_args(args)
   reset()
end

function love.update(dt)
   if game_terminating then
      love.event.quit()
   end
   if game_resetting then
      reset()
   end
   if game_paused then
      return
   end

   player_input:tick(dt)
   update(dt)

   devtools.tick()
end

function love.draw()
   if game_resetting then
      return
   end
   render()
end
