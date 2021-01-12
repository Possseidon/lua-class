local class = require "class"

---@class Object: class
---@type fun(): Object
local Object = class("Object")

Object.properties = {}

---Copies over existing properties in the base class into the new class.
---@param base Object
function Object:inherit(base)
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

---Deals with property getters.
---@param key string
---@return any
function Object.metatable:index(key)
  local property = rawget(self.properties, key)
  if property then
    local get = property.get
    if get then
      return get(self)
    end
    error("property " .. self.classname .. "." .. key .. " is not readable", 2)
  end
end

---Deals with property setters.
---@param key string
---@param value any
function Object.metatable:__newindex(key, value)
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

---Returns the properties table of the class or object.
---@return table properties
local function getProperties(self)
  assert(class.isClass(self), "properties are class specific")
  return self.properties
end

---Adds a read-only property for a field.
---@param name string The name of the property.
---@param field? string The name of the backing field; defaults to `_<name>`.
function Object:addReadonly(name, field)
  local properties = getProperties(self)
  field = field or ("_" .. name)
  properties[name].get = function(self)
    return self[field]
  end
end

---Adds an Event property which uses the setter to add a new handler
---@param name string The name of the Event property.
---@param field? string The name of the backing field; defaults to `_<name>`.
function Object:addEvent(name, field)
  local properties = getProperties(self)
  field = field or ("_" .. name)
  properties[name].get = function(object)
    return object[field]
  end
  properties[name].set = function(object, value)
    object[field]:add(value)
  end
end

---Adds a property for a field with an optional event handler.
---@param name string The name of the property.
---@param field? string The name of the backing field; defaults to `_<name>`.
---@param event? string The name of the event; defaults to `_on<Name>Change`.
function Object:addProperty(name, field, event)
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

return Object
