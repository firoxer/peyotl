local Component = require("src.engine.ecs.component")

local HealthComponent = prototype(
   Component("health"),
   function(self, amount, max_amount)
      self.amount = amount
      self.max_amount = max_amount
   end
)

return HealthComponent
