local class = require "class"

local TPrint = class("TPrint")

-- define a constructor which is called for all newly created instances
function TPrint:create(value)
  print("new TPrint: " .. value)

  -- fields are usually created in the constructor
  -- fields cannot be made private, but it is an idiom to prefix them with "_"
  self._value = value
end

-- creates a new instance and calls "create" on it automatically
TPrint("Hello World!") --> new TPrint: Hello World!
