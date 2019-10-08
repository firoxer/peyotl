--- Set globals to make development and testing nicer

game_debug = {}

ds =
   require("game.util.ds")

hsl =
   require("game.util.hsl")

instantiate =
   require("game.util.instantiate")

log =
   require("game.util.log")

string.camelcasify =
   require("game.util.string.camelcasify")

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
