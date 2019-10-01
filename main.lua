require("./init")

local devtools = require("devtools")
local seed = require("seed")

local EntityManager = require("game.entity.entity_manager")
local PlayerInput = require("game.player_input")
local render_co = require("game.render_co")
local update_co = require("game.update_co")
local config = require("game.config")
local events = require("game.event.events")
local generate = require("game.generate")

local game_paused = false
local game_terminating = false
local game_restarting = false

local entity_manager = EntityManager.new()
local player_input = PlayerInput.new(config.player_input)

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

   update = update_co(config.levels, entity_manager, player_input)
   render = render_co(config.rendering, config.levels, entity_manager)

   generate(entity_manager, config)
end

function love.load(arg)
   if table.contains(arg, "--help") then
      print([[usage: ./run [options]
    --profile
    --report-memory-usage
    --report-low-fps
    --retard-performance]])
      love.event.quit()
   end
   if table.contains(arg, "--dev") then
      -- Default flags for dev
      table.insert(arg, "--report-low-fps")
      table.insert(arg, "--retard-performance")
   end

   for i = 1, #arg do
      if arg[i] == "--profile" then
         devtools.enable_profiler_reports()
      elseif arg[i] == "--report-memory-usage" then
         devtools.enable_memory_usage_reports()
      elseif arg[i] == "--report-low-fps" then
         devtools.enable_low_fps_reports()
      elseif arg[i] == "--retard-performance" then
         devtools.enable_performance_retardation()
      end
   end

   reset()
end

function love.update(dt)
   if game_terminating then
      love.event.quit()
   end
   if game_restarting then
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
   render()
end
