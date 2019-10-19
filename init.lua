--- Set globals to make development and testing nicer

-- This ought to be #1 because it may be used anywhere
game_debug = {}

-- This has to come before `prototypify`
string.camelcasify =
   require("game.util.string.camelcasify")

-- This has to come before `ds`
prototypify =
   require("game.util.prototypify")

ds =
   require("game.util.ds")

log =
   require("game.util.log")

table.clone =
   require("game.util.table.clone")

table.contains =
   require("game.util.table.contains")

table.describe =
   require("game.util.table.describe")

table.merge =
   require("game.util.table.merge")

table.readonly =
   require("game.util.table.readonly")

table.reverse =
   require("game.util.table.reverse")

table.sample =
   require("game.util.table.sample")

table.shuffle =
   require("game.util.table.shuffle")

table.uptight =
   require("game.util.table.uptight")

math.round =
   function(n, multiple)
      return math.floor(n / multiple + 0.5) * multiple
   end

if love == nil then
   -- For tests
   love = {
      math = {
         random = math.random
      }
   }
end
