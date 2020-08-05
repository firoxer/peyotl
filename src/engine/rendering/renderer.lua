local make_render_by_component = require("src.engine.rendering.make_render_by_component")
local make_render_debug_overlay = require("src.engine.rendering.make_render_debug_overlay")
local make_render_ui = require("src.engine.rendering.make_render_ui")

local Renderer = {}

function Renderer:initialize(rendering_config, level_config, entity_manager, tileset)
   self._tileset = tileset

   self._render_by_component =
      make_render_by_component(
         rendering_config,
         level_config,
         entity_manager,
         tileset
      )

   self._render_ui =
      make_render_ui(rendering_config, entity_manager)

   if rendering_config.debug_overlay_enabled then
      local render_debug_overlay = make_render_debug_overlay()

      self.render = function()
         self:render()
         render_debug_overlay()
      end
   end
end

function Renderer:render()
   self._render_by_component()
   self._render_ui()
end

local prototype = prototypify(Renderer)
return prototype