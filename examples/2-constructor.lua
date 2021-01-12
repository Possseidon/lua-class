local class = require "class"

local Print = class("Print")

-- Define a constructor which is called for all newly created instances.
function Print:create(value)
  print("new Print: " .. value)

  -- Fields are usually created in the constructor.
  -- They cannot be made private, but it is an idiom to prefix them with "_".
  self._value = value
end

-- Creates a new instance and calls "create" on it automatically.
Print("Hello World!") --> new Print: Hello World!
