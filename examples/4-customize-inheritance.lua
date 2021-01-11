local class = require "class"

local Base = class("Base")

-- it is possible to customize the inheritance process
function Base:inherit(base)
  -- "self" is the class that inherits
  -- "base" its direct base class
  print(self.classname .. " inherits " .. base.classname)
  -- e.g. Object uses this to copy over all properties
end

local Derived = class("Derived", Base) --> Derived inherits Base

class("DoubleDerived", Derived) --> DoubleDerived inherits Derived

-- can be overridden like any other method
function Derived:inherit(base)
  print("I'm different!")
end

class("DifferentDerived", Derived) --> I'm different!
