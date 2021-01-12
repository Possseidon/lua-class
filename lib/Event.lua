local class = require "class"

---@class Event: class
---@type fun(): Event
---@type fun(...)
local Event = class("Event")

---Appends a new event handler.
---@param handler any
function Event:add(handler)
  table.insert(self, handler)
end

---Removes an existing event handler, raising an error if it doesn't actually exist.
---@param handler any
function Event:remove(handler)
  for i = #self, 1, -1 do
    if self[i] == handler then
      table.remove(self, i)
      return
    end
  end
  error("event handler not found", 2)
end

---Calls all event handlers in the order they were added with the given parameters.
---@vararg any
function Event.metatable:__call(...)
  for i = 1, #self do
    self[i](...)
  end
end

return Event
