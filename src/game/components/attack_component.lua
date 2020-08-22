local Component = require("src.engine.ecs.component")

local AttackComponent = prototype(
   Component("attack"),
   function(self, amount, time_between_attacks, time_at_last_attack)
      assertx.is_number(amount)
      assertx.is_number(time_between_attacks)
      assertx.is_number_or_nil(time_at_last_attack)

      self.amount = amount
      self.range = 1
      self.time_at_last_attack = time_at_last_attack or 0
      self.time_between_attacks = time_between_attacks
   end
)

return AttackComponent