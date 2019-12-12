local make_render_background = require("game.render.make_render_background")

do
   local render_background = make_render_background()
   assert(type(render_background) == "function")
end
