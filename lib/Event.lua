local class = require "class"

local Event = class("Event")

function Event:add(handler)
  table.insert(self, handler)
end

function Event:remove(handler)
  for i = #self, 1, -1 do
    if self[i] == handler then
      table.remove(self, i)
      return
    end
  end
  error("event handler not found", 2)
end

function Event.metatable:__call(...)
  for i = 1, #self do
    self[i](...)
  end
end

return Event
