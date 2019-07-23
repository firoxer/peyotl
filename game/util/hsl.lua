-- RGBA to HSLA, from https://love2d.org/wiki/HSL_color
-- Modified to return tables instead of multiple values
-- Modified to use 0-1 as a range instead of 0-255
return function(h, s, l, a)
	if s <= 0 then
      return { l, l, l, a }
   end

	h = h * 6
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = (1 - math.abs(h % 2 - 1)) * c
	local m = (l - .5 * c)

   local r, g, b
	if h < 1 then
      r, g, b = c, x, 0
	elseif h < 2 then
      r, g, b = x, c, 0
	elseif h < 3 then
      r, g, b = 0, c, x
	elseif h < 4 then
      r, g, b = 0, x, c
	elseif h < 5 then
      r, g, b = x, 0, c
	else
      r, g, b = c, 0, x
	end

   return { (r + m), (g + m), (b + m), a }
end
