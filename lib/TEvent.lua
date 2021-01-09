local class = require "class"

local TEvent = class("TEvent")

function TEvent:add(handler)
  table.insert(self, handler)
end

function TEvent:remove(handler)
  for i = #self, 1, -1 do
    if self[i] == handler then
      table.remove(self, i)
      return
    end
  end
  error("event handler not found", 2)
end

function TEvent.metatable:__call(...)
  for i = 1, #self do
    self[i](...)
  end
end

return TEvent
