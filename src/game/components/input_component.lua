local Component = require("src.engine.ecs.component")

local InputComponent = prototype(
   Component("input"),
   function(self)
      self.pending_events = ds.Queue()
   end
)

return InputComponent
