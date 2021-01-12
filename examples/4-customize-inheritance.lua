local class = require "class"

local Base = class("Base")

-- It is possible to customize the inheritance process.
function Base:inherit(derived)
  -- "self" is the base class that inherits.
  -- "derived" the class that inherited it.
  print(derived.classname .. " inherits from " .. self.classname)
  -- E.g. the Object class uses this to copy over all properties.
end

local Derived = class("Derived", Base) --> Derived inherits from Base

class("DoubleDerived", Derived) --> DoubleDerived inherits from Derived

-- It can be overridden like any other method.
function Derived:inherit()
  print("I'm different!")
end

class("DifferentDerived", Derived) --> I'm different!
