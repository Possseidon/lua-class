---@class class
---@field class class
---@field baseclass class
---@field classname string
---@field metatable table
---@field makeAbstract fun(name: string)
---@field create function
---@field inherit function

local classes = setmetatable({}, {__mode = "k"})
local objects = setmetatable({}, {__mode = "k"})

---Creates an abstract function with the given name that always throws.
---@param self class
---@param name string
local function makeAbstract(self, name)
  self[name] = function(class)
    error(("attempt to call abstract %s:%s"):format(class.classname, name), 2)
  end
end

---Creates a new instance of a class.
---@param self class
---@vararg any
---@return class
local function newObject(self, ...)
  local object = {}
  setmetatable(object, self.metatable)
  objects[object] = true
  local create = object.create
  if create then
    create(object, ...)
  end
  return object
end

---Returns the class of an instance, forwards classes and otherwise returns `nil`.
---@param entity any
---@return class?
local function classOf(entity)
  return classes[entity] and entity or
    objects[entity] and entity.class
end

---Checks, if two entities have the exact same class type using `class.of` on both operands.
---@param a any
---@param b any
---@return boolean
local function isExact(a, b)
  return rawequal(classOf(a), classOf(b))
end

---Checks, if the second parameter matches or derives from the first parameter.
---@param a any
---@param b any
---@return boolean
local function isExactOrBase(a, b)
  local base = classOf(a)
  if not base then
    return true
  end
  local derived = classOf(b)
  while derived do
    if rawequal(derived, base) then
      return true
    end
    derived = derived.baseclass
  end
  return false
end

---Checks, if the second parameter derives from the first parameter.
---@param a any
---@param b any
---@return boolean
local function isBase(a, b)
  local base = classOf(a)
  if not base then
    return true
  end
  local derived = classOf(b)
  while derived do
    derived = derived.baseclass
    if rawequal(derived, base) then
      return true
    end
  end
  return false
end

---Adds a new __index handler to the given metatable.
---Only if the previous __index handler returns `nil`, this new handler is used.
---@param metatable table
---@param index table|function
local function addIndexHandler(metatable, index)
  local oldIndex = metatable.__index
  if not oldIndex then
    metatable.__index = index
  elseif type(oldIndex) == "function" then
    if type(index) == "function" then
      function metatable:__index(key)
        local old = oldIndex(self, key)
        return old ~= nil and old or index(self, key)
      end
    else
      function metatable:__index(key)
        local old = oldIndex(self, key)
        return old ~= nil and old or index[key]
      end
    end
  else
    if type(index) == "function" then
      function metatable:__index(key)
        local old = oldIndex[key]
        return old ~= nil and old or index(self, key)
      end
    else
      function metatable:__index(key)
        local old = oldIndex[key]
        return old ~= nil and old or index[key]
      end
    end
  end
end

---Returns a new class with the given name and optional base class.
---@param classname string
---@param baseclass? any
---@return class class
---@return class? super
local function newClass(_, classname, baseclass)
  local metatable = {}

  local class = setmetatable({
    baseclass = baseclass,
    classname = classname,
    metatable = metatable,
    makeAbstract = makeAbstract
  }, {
    __name = classname,
    __call = newObject,
    __index = baseclass,
    __eq = isExact,
    __le = isExactOrBase,
    __lt = isBase,
    __metatable = false
  })

  if baseclass then
    for k, v in pairs(baseclass.metatable) do
      metatable[k] = v
    end
  end
  metatable.__metatable = false
  metatable.__name = classname .. "()"

  local old = metatable.__index
  metatable.__index = class
  if old then
    addIndexHandler(metatable, old)
  end

  setmetatable(metatable, {
    __newindex = function(mt, key, value)
      if key == "index" then
        addIndexHandler(mt, value)
      else
        rawset(mt, key, value)
      end
    end
  })

  class.class = class
  classes[class] = true
  if baseclass then
    local inherit = baseclass.inherit
    if inherit then
      inherit(class, baseclass)
    end
  end
  return class, baseclass
end

---Checks if the given thing is any class.
---@param class any
---@return boolean
local function isClass(class)
  return classes[class] or false
end

---Checks if the given thing is any object.
---@param object any
---@return boolean
local function isObject(object)
  return objects[object] or false
end

---The class library.
---@class class*
---@type fun(name: string, base?: class)
local class = setmetatable({
  isClass = isClass,
  isObject = isObject,
  of = classOf
}, {
  __call = newClass
})

return class
