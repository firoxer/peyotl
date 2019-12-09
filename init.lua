--- Set globals to make development and testing nicer

-- This ought to be #1 because it may be used anywhere
game_debug = {}

assertx = {}

assertx.is_boolean =
   require("game.util.assertx.is_boolean")

assertx.is_boolean_or_nil =
   require("game.util.assertx.is_boolean_or_nil")

assertx.is_function =
   require("game.util.assertx.is_function")

assertx.is_function_or_nil =
   require("game.util.assertx.is_function_or_nil")

assertx.is_instance_of =
   require("game.util.assertx.is_instance_of")

assertx.is_instance_of_or_nil =
   require("game.util.assertx.is_instance_of_or_nil")

assertx.is_number =
   require("game.util.assertx.is_number")

assertx.is_number_or_nil =
   require("game.util.assertx.is_number_or_nil")

assertx.is_string =
   require("game.util.assertx.is_string")

assertx.is_string_or_nil =
   require("game.util.assertx.is_string_or_nil")

assertx.is_table =
   require("game.util.assertx.is_table")

assertx.is_table_or_nil =
   require("game.util.assertx.is_table_or_nil")

assertx.is_true =
   require("game.util.assertx.is_true")

stringx = {}

stringx.camelcasify =
   require("game.util.stringx.camelcasify")

tablex = {}

tablex.clone =
   require("game.util.tablex.clone")

tablex.contains =
   require("game.util.tablex.contains")

tablex.describe =
   require("game.util.tablex.describe")

tablex.mappairs =
   require("game.util.tablex.mappairs")

tablex.merge =
   require("game.util.tablex.merge")

tablex.readonly =
   require("game.util.tablex.readonly")

tablex.reverse =
   require("game.util.tablex.reverse")

tablex.sample =
   require("game.util.tablex.sample")

tablex.shuffle =
   require("game.util.tablex.shuffle")

tablex.uptight =
   require("game.util.tablex.uptight")

-- This has to come before `ds`
prototypify =
   require("game.util.prototypify")

ds =
   require("game.util.ds")

log =
   require("game.util.log")

mathx = {}

mathx.round =
   require("game.util.mathx.round")

if love == nil then
   -- For tests
   love = {
      math = {
         random = math.random
      }
   }
end
