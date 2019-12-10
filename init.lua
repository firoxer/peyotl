--- Set globals to make development and testing nicer

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

if love == nil then
   -- For tests
   love = {
      math = {
         random = math.random
      }
   }
end
