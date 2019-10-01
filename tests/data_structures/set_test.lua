local Set = require("../game/data_structures/set")

do
   local s = Set.new()
   s:add('a')
   s:add('b')
   s:add('c')
   assert(s:contains('a'))
   assert(s:contains('b'))
   assert(s:contains('c'))
end

do
   local s = Set.new()
   s:add('a')
   s:add('b')
   s:add('c')
   s:remove('c')
   assert(not s:contains('c'))
end

do
   local s = Set.new()
   s:add('a')
   s:remove('a')
   s:add('a')
   assert(s:contains('a'))
end

do
   local s = Set.new()
   s:add('a')
   s:add('a')
   s:add('a')
   assert(s:size() == 1)
end
