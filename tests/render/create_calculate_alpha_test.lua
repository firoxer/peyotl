local create_calculate_alpha = require("game.render.create_calculate_alpha")

local test_illuminabilities = ds.Matrix.new()
test_illuminabilities:set(ds.Point.new(0, 0), true)
test_illuminabilities:set(ds.Point.new(0, 1), true)
test_illuminabilities:set(ds.Point.new(0, 2), true)
test_illuminabilities:set(ds.Point.new(1, 0), true)
test_illuminabilities:set(ds.Point.new(1, 1), true)
test_illuminabilities:set(ds.Point.new(1, 2), true)
test_illuminabilities:set(ds.Point.new(2, 0), true)
test_illuminabilities:set(ds.Point.new(2, 1), true)
test_illuminabilities:set(ds.Point.new(2, 2), true)

do
   local settings = { algorithm = "full" }
   local calculate_alpha = create_calculate_alpha(settings, test_illuminabilities, ds.Point.new(1, 1))
   assert(calculate_alpha(ds.Point.new(0, 0) == 1))
   assert(calculate_alpha(ds.Point.new(2, 2) == 1))
end

do
   local settings = {
      algorithm = "fog_of_war",
      lighting_range = 0,
   }
   local calculate_alpha = create_calculate_alpha(settings, test_illuminabilities, ds.Point.new(0, 0))
   assert(calculate_alpha(ds.Point.new(0, 0)) == 1)
   assert(calculate_alpha(ds.Point.new(0, 1)) == 0.5)
   assert(calculate_alpha(ds.Point.new(0, 2)) == 0)
   assert(calculate_alpha(ds.Point.new(1, 0)) == 0.5)
   assert(calculate_alpha(ds.Point.new(2, 0)) == 0)
end

do
   local settings = {
      algorithm = "fog_of_war",
      lighting_range = 1,
   }
   local calculate_alpha = create_calculate_alpha(settings, test_illuminabilities, ds.Point.new(0, 0))
   assert(calculate_alpha(ds.Point.new(0, 0)) == 1)
   assert(calculate_alpha(ds.Point.new(0, 1)) == 1)
   assert(calculate_alpha(ds.Point.new(0, 2)) == 0.5)
   assert(calculate_alpha(ds.Point.new(1, 0)) == 1)
   assert(calculate_alpha(ds.Point.new(2, 0)) == 0.5)
end
