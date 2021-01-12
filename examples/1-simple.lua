-- require the class library
local class = require "class"

-- create a new class Value
local Value = class("Value")

-- add a some member functions using ":" and "self"
function Value:get()
  return self._value
end

function Value:set(value)
  self._value = value
end

-- create an instance
local value = Value()

-- ...and use it!
value:set("Hello World!")
print(value:get()) --> Hello World!
