-- Require the class library.
local class = require "class"

-- Create a new class Value.
local Value = class("Value")

-- Add a some member functions using ":" and "self".
function Value:get()
  return self._value
end

function Value:set(value)
  self._value = value
end

-- Create an instance...
local value = Value()

-- and use it!
value:set("Hello World!")
print(value:get()) --> Hello World!
