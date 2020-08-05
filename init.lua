--- Set globals to make development and testing nicer

-- For debugging
if os.getenv("DEBUG") == "true" then
   require("lldebugger").start()
end

-- For tests
if love == nil then
   love = {
      graphics = {
         newImage = function()
            return {
               getWidth = function()
                  return 1
               end,
               getHeight = function()
                  return 1
               end,
               setFilter = function()
               end,
            }
         end,

         newQuad = function()
            return nil
         end,
      },

      math = {
         random = math.random,
      },

      timer = {
         getTime = os.clock
      },

      system = {
         getOS = function()
            return nil
         end,
      }
   }
end

-- This ought to be #1 because it may be used anywhere
game_debug = {}

-- Standard library extensions
assertx = require("src.util.assertx")
stringx = require("src.util.stringx")
tablex = require("src.util.tablex")
mathx = require("src.util.mathx")

prototypify = require("src.util.prototypify") -- This has to come before `ds`
ds = require("src.util.ds")
log = require("src.util.log")
