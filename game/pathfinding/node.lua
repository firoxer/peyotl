local Node = {}

function Node:reset()
   self.opened = false
   self.closed = false
   self.parent = nil
   self.cost = nil
end

local create_object = prototypify(Node)
return {
   new = function(point)
      assert(type(point.x) == "number")
      assert(type(point.y) == "number")

      local self = create_object({
         x = point.x,
         y = point.y,
      })
      self:reset()
      return self
   end
}