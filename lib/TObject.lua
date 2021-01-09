local class = require "class"

local TObject = class("TObject")

TObject.properties = {}

function TObject:inherit(base)
  local properties = setmetatable({}, {
    __index = function(t, k)
      local prop = {}
      t[k] = prop
      return prop
    end
  })
  if base then
    for k, v in pairs(base.properties) do
      properties[k] = v
    end
  end
  self.properties = properties
end

function TObject.metatable:index(key)
  local property = rawget(self.properties, key)
  if property then
    local get = property.get
    if get then
      return get(self)
    end
    error("property " .. self.classname .. "." .. key .. " is not readable", 2)
  end
end

function TObject.metatable:__newindex(key, value)
  local property = rawget(self.properties, key)
  if property then
    local set = property.set
    if set then
      set(self, value)
    else
      error("property " .. self.classname .. "." .. key .. " is not writable", 2)
    end
  else
    rawset(self, key, value)
  end
end

local function getProperties(self)
  assert(class.isClass(self), "properties are class specific")
  return self.properties
end

-- Adds a read-only property for a field
-- The data field name defaults to "_<name>"
function TObject:addReadonly(name, field)
  local properties = getProperties(self)
  field = field or ("_" .. name)
  properties[name].get = function(self)
    return self[field]
  end
end

-- Adds an event property which uses the setter to add a new handler
-- The event field name defaults to "_<name>"
function TObject:addEvent(name, field)
  local properties = getProperties(self)
  field = field or ("_" .. name)
  properties[name].get = function(object)
    return object[field]
  end
  properties[name].set = function(object, value)
    object[field]:add(value)
  end
end

-- Adds a property for a field with an optional event handler
-- The data field name defaults to "_<name>"
-- The event field name defaults to "_on<Name>Change" (name is capitalized)
function TObject:addProperty(name, field, event)
  local properties = getProperties(self)
  field = field or ("_" .. name)
  event = event or ("_on" .. name:gsub("^%l", string.upper) .. "Change")
  properties[name].get = function(object)
    return object[field]
  end
  properties[name].set = function(object, value)
    local oldValue = object[field]
    if oldValue ~= value then
      object[field] = value
      object[event](object, oldValue)
    end
  end
end

return TObject
