--- Set globals to make development and testing nicer

-- Stolen from http://lua-users.org/wiki/LuaModulesLoader
local function type_assertion_inserting_loader(module_name)
   local error_msg = ""
   local modulepath = string.gsub(module_name, "%.", "/")
   for path in string.gmatch(package.path, "([^;]+)") do
      local filename = string.gsub(path, "%?", modulepath)

      local file = io.open(filename, "rb")
      if file then
         local main_code_lines = {}
         local typechecked_code_lines = {}
         local assertions = {}
         for line in file:lines() do
            local function_signature = line:match("^%-%-s (.+)")

            if line == "end" and #assertions >= 1 then
               table.insert(main_code_lines, '-- HEY HO')
            end

            if function_signature then
               for signature_part in function_signature:gmatch("([%a|]+)") do
                  if signature_part:find("|") then
                     -- It's a union
                     print("TODO")
                  elseif signature_part:find("%(") then
                     -- It's a tuple
                     print("TODO")
                  else
                     -- It's nothing unusual
                     if signature_part == "string" then
                        table.insert(assertions, assertx.is_string)
                     else
                        -- TODO
                     end
                  end
               end
            end

            table.insert(main_code_lines, line)
         end
         print(table.concat(main_code_lines, "\n"))
         local executable_code = loadstring(table.concat(main_code_lines, "\n"), filename)
         assert(executable_code)
         return executable_code
      end

      error_msg = error_msg.."\n\tno file '"..filename.."' (checked with custom loader)"
   end

   return error_msg
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
         random = math.random
      },

      system = {
         getOS = function()
            return nil
         end
      },
   }
end

table.insert(package.loaders, 2, type_assertion_inserting_loader)

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
