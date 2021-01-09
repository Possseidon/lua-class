local classes = setmetatable({}, {__mode = "k"})
local objects = setmetatable({}, {__mode = "k"})

local function makeAbstract(self, name)
  self[name] = function(class)
    error(("attempt to call abstract %s:%s"):format(class.classname, name), 2)
  end
end

local function newObject(self, ...)
  local object = {
    class = self
  }
  object.inherited = setmetatable({
    metatable = setmetatable({}, {
      __index = function(_, name)
        return function(...)
          return self.baseclass.metatable[name](object, ...)
        end
      end,
      __metatable = false
    })
  }, {
    __index = function(_, name)
      return function(...)
        return self.baseclass[name](object, ...)
      end
    end,
    __metatable = false
  })
  setmetatable(object, self.metatable)
  objects[object] = true
  local create = object.create
  if create then
    create(object, ...)
  end
  return object
end

local function classOf(entity)
  return classes[entity] and entity or
    objects[entity] and entity.class
end

local function isExact(a, b)
  return rawequal(classOf(a), classOf(b))
end

local function isExactOrBase(a, b)
  local base = classOf(a)
  if not base then return true end
  local derived = classOf(b)
  while derived do
    if rawequal(derived, base) then
      return true
    end
    derived = derived.baseclass
  end
  return false
end

local function isBase(a, b)
  local base = classOf(a)
  if not base then return true end
  local derived = classOf(b)
  while derived do
    derived = derived.baseclass
    if rawequal(derived, base) then
      return true
    end
  end
  return false
end

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

local function newClass(_, classname, baseclass)
  local metatable = {}
  local class = setmetatable({
    baseclass = baseclass,
    classname = classname,
    metatable = metatable,
    makeAbstract = makeAbstract
  }, {
    __name = classname or "class",
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
  metatable.__name = classname and classname .. "()" or "object"

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
  return class
end

local function isClass(class)
  return classes[class] or false
end

local function isObject(object)
  return objects[object] or false
end

return setmetatable({
  isClass = isClass,
  isObject = isObject,
  of = classOf
}, {
  __call = newClass
})
