local class = require "class"

local TBase = class("TBase")

-- it is possible to customize the inheritance process
function TBase:inherit(base)
  -- "self" is the class that inherits
  -- "base" its direct base class
  print(self.classname .. " inherits " .. base.classname)
  -- e.g. TObject uses this to copy over all properties
end

local TDerived = class("TDerived", TBase) --> TDerived inherits TBase

class("TDoubleDerived", TDerived) --> TDoubleDerived inherits TDerived

-- can be overridden like any other method
function TDerived:inherit(base)
  print("I'm different!")
end

class("TDifferentDerived", TDerived) --> I'm different!
