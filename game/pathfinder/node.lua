local Node = {}

function Node:reset()
   self.opened = false
   self.closed = false
   self.parent = nil
   self.cost = nil
end

return {
   new = function(point)
      assert(type(point.x) == "number")
      assert(type(point.y) == "number")

      local instance = instantiate(Node, {
         x = point.x,
         y = point.y,
      })
      instance:reset()
      return instance
   end
}
