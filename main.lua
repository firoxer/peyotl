require("./init")

local config = require("config")
local devtools = require("devtools")
local seed = require("seed")

local EntityManager = require("game.entity.entity_manager")
local PlayerInput = require("game.player_input")
local Subject = require("game.event.subject")
local events = require("game.event.events")
local generate = require("game.generate")
local make_render = require("game.make_render")
local make_update = require("game.make_update")

local arg_reactions = {
   disable_vsync = function()
      config.rendering.enable_vsync = false
      log.debug("disabled vsync")
   end,

   log_events = function()
      Subject.enable_event_logging()
      log.debug("enabled event logging")
   end,

   profile = function()
      devtools.enable_profiling()
      log.debug("enabled profiling")
   end,

   report_memory_usage = function()
      devtools.enable_memory_usage_reports()
      log.debug("enabled memory usage reports")
   end,

   report_low_fps = function()
      devtools.enable_low_fps_reports()
      log.debug("enabled low FPS reports")
   end,

   retard_performance = function()
      devtools.enable_performance_retardation()
      log.debug("enabled performance retardation")
   end,
}
local function parse_args(raw_args)
   local args = {
      -- Defaults for development
      report_low_fps = true,
      retard_performance = true
   }

   for _, arg in ipairs(raw_args) do
      local key = arg:match("^%-%-([%w%-]+)=?")
      local value = arg:match("=(%w*)$")
      if not key then
         log.error("invalid argument: " .. arg)
         love.event.quit()
      end
      args[key:gsub("-", "_")] = value or true
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

   if args.production then
      args.report_low_fps = nil
      args.retard_performance = nil
      args.production = nil
   end

   for key, value in pairs(args) do
      if not arg_reactions[key] then
         log.error("no reaction for CLI arg: " .. key)
      else
         arg_reactions[key](value)
      end
   end
end

local game_paused = false
local game_terminating = false
local game_resetting = false

local player_input = PlayerInput.new(config.player_input)

local entity_manager

player_input.subject:subscribe(events.quit_game, function()
   game_terminating = true
end)
player_input.subject:subscribe(events.toggle_game_pause, function()
   game_paused = not game_paused
end)

local update
local render

local function reset()
   seed()

   entity_manager = EntityManager.new()

   entity_manager.subject:subscribe(events.entity_removed, function(event_data)
      if event_data.entity_id == entity_manager:get_registered_entity_id("player") then
         game_resetting = true
      end
   end)

   entity_manager:register_entity_id(entity_manager:new_entity_id(), "player")
   entity_manager:register_entity_id(entity_manager:new_entity_id(), "altar_1")
   entity_manager:register_entity_id(entity_manager:new_entity_id(), "altar_2")
   entity_manager:register_entity_id(entity_manager:new_entity_id(), "altar_3")
   entity_manager:register_entity_id(entity_manager:new_entity_id(), "altar_4")

   update = make_update(config.levels, entity_manager, player_input)
   render = make_render(config.rendering, config.levels, entity_manager)

   generate(entity_manager, config)

   game_resetting = false
end

function love.load(args)
   parse_args(args)
   reset()
end

function love.update(dt)
   player_input:tick(dt)

   if game_terminating then
      love.event.quit()
   end
   if game_resetting then
      reset()
   end
   if game_paused then
      return
   end

   update(dt)

   devtools.tick()
end

function love.draw()
   if game_resetting then
      return
   end
   render()
end
