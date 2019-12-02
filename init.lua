--- Set globals to make development and testing nicer

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
         random = math.random
      },

      system = {
         getOS = function()
            return nil
         end
      }
   }
end

-- This ought to be #1 because it may be used anywhere
game_debug = {}

-- Standard library extensions
assertx = require("game.util.assertx")
stringx = require("game.util.stringx")
tablex = require("game.util.tablex")
mathx = require("game.util.mathx")

prototypify = require("game.util.prototypify") -- This has to come before `ds`
ds = require("game.util.ds")
log = require("game.util.log")
