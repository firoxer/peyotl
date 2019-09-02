require("./init")

local config = require("config")
local extra = require("extra")
local seed = require("seed")

local EntityManager = require("game.entity.entity_manager")
local bind_player_input_to_love = require("game.bind_player_input_to_love")
local render_co = require("game.render_co")
local update_co = require("game.update_co")
local events = require("game.event.events")
local generate = require("game.generate")
local subjects = require("game.event.subjects")

local entity_manager = EntityManager.new()
local game_state = { paused = false, terminating = false, restarting = false }
local tick_input = bind_player_input_to_love(config.player_input)

local update
local render

local function reset()
   seed()

   update = coroutine.wrap(update_co)
   update(config.levels, entity_manager)

   render = coroutine.wrap(render_co)
   render(config.rendering, config.levels, entity_manager)

   generate(entity_manager, config)
end

subjects.player_input:subscribe(function(event)
   if event == events.quit_game then
      game_state.terminating = true
   elseif event == events.toggle_game_pause then
      game_state.paused = not game_state.paused
   end
end)

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
         extra.enable_profiler_reports()
      elseif arg[i] == "--report-memory-usage" then
         extra.enable_memory_usage_reports()
      elseif arg[i] == "--report-low-fps" then
         extra.enable_low_fps_reports()
      elseif arg[i] == "--retard-performance" then
         extra.enable_performance_retardation()
      end
   end

   reset()
end

function love.update(dt)
   if game_state.paused then
      return
   end
   if game_state.terminating then
      love.event.quit()
   end
   if game_state.restarting then
      reset()
   end

   tick_input(dt)
   update(dt)

   extra.tick()
end

function love.draw()
   render(config.rendering, config.levels, entity_manager)
end
