-- Basic method
do
   local Prototype = prototype()

   function Prototype:perform()
      self.prop = 1
   end

   local instance = Prototype()

   assert(instance.prop == nil)

   instance:perform()

   assert(instance.prop == 1)
end

-- Implicit call to initialize
do
   local Prototype = prototype(function(self)
      self.prop = 1
   end)

   local instance = Prototype()

   assert(instance.prop == 1)
end

-- Calling parent's method
do
   local ParentPrototype = prototype()

   function ParentPrototype:perform()
      self.prop = 1
   end

   local Prototype = prototype(ParentPrototype)

   local instance = Prototype()

   assert(instance.prop == nil)

   instance:perform()

   assert(instance.prop == 1)
end

-- Calling redefined method
do
   local ParentPrototype = prototype()

   function ParentPrototype:perform()
      self.prop = 1
   end

   local ChildPrototype = prototype(ParentPrototype)

   function ChildPrototype:perform()
      self.prop = 2
   end

   local instance = ChildPrototype()

   assert(instance.prop == nil)

   instance:perform()

   assert(instance.prop == 2)
end

-- Calling grandparent's method
do
   local GrandparentPrototype = prototype()

   function GrandparentPrototype:perform()
      self.prop = 1
   end

   local ParentPrototype = prototype(GrandparentPrototype)

   local Prototype = prototype(ParentPrototype)

   local instance = Prototype()

   assert(instance.prop == nil)

   instance:perform()

   assert(instance.prop == 1)
end

-- Ensuring only the last initialization gets called
do
   local ParentPrototype = prototype(function(self)
      self.parentCalled = true
   end)

   local Prototype = prototype(ParentPrototype, function(self)
      self.called = true
   end)

   local instance = Prototype()

   assert(instance.called == true)
   assert(instance.parentCalled == nil)
end