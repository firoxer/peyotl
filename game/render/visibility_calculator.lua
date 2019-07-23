local Point = require("game.data_structures.point")

local VisibilityCalculator = {}

function VisibilityCalculator:calculate(target_point)
   local rough_dist = Point.chebyshev_distance(target_point, self._light_source)
   if rough_dist > self._max_range then
      -- If it's not within Chebyshev distance, it's not within Euclidean either
      return 0
   end

   local exact_dist = Point.euclidean_distance(target_point, self._light_source)

   if exact_dist > self._max_range then
      return 0
   end

   local illuminable =
      Point.bresenham_line(self._light_source, target_point, function(point)
         return self._is_illuminable_at(point) or point == self._light_source
      end)

   if not illuminable then
      return 0
   end

   return math.min(1, (self._max_range - exact_dist) / (self._max_range - self._dimming_range))
end

function VisibilityCalculator:set_light_source(point)
   self._light_source = point
end

return {
   new = function(is_illuminable_at, max_range, dimming_range)
      assert(type(is_illuminable_at) == "function")
      assert(type(max_range) == "number")
      assert(type(dimming_range) == "number")

      local instance = instantiate(VisibilityCalculator, {
         _is_illuminable_at = is_illuminable_at,

         _max_range = max_range,
         _dimming_range = dimming_range,

         _light_source = nil,
      })
      return instance
   end
}
