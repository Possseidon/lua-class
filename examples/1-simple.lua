-- require the class library
local class = require "class"

-- create a new class TValue
local TValue = class("TValue")

-- add a some member functions using ":" and "self"
function TValue:get()
  return self._value
end

-- of course, ":" is just syntacic sugar and this also works:
function TValue.set(self, value)
  self._value = value
end

-- create an instance
local value = TValue()

-- ...and use it!
value:set("Hello World!")
print(value:get()) --> Hello World!
