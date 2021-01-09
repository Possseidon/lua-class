local class = require "class"

---- Creating a base class TAnimal with virtual and abstract methods

-- classes do not have to inherit
-- likewise, TObject is NOT the ultimate base class of all other classes
local TAnimal = class("TAnimal")

function TAnimal:create(name)
  self._name = name
end

-- by virtue of the way Lua works, all methods are "virtual"
function TAnimal:move()
  print(self._name .. " moves")
end

-- calling TAnimal:speak will raise an error
TAnimal:makeAbstract "speak"

local _, err = pcall(function()
  local animal = TAnimal("Peter")
  animal:move() --> Peter moves
  animal:speak() --> abstract call error, see below
end)

print(err) --> [...]: attempt to call abstract TAnimal:speak

---- Creating a subclass TCat, overriding existing methods

-- inheritance can be achieved by simply passing the base class as a second parameter
-- multiple inheritance is NOT supported currently, but may be introduced at some point
local TCat = class("TCat", TAnimal)

-- overriding the existing constructor
function TCat:create(...)
  -- using the self.inherited wrapper, the base constructor can be called
  -- note that self is automatically forwarded, despite not using the ":" method call syntax
  self.inherited.create(...)
  -- this is basically equivalent to
  self.baseclass.create(self, ...)
  -- or simply using the base class directly
  TAnimal.create(self, ...)
  -- however care has to be taken, if the base class changes at some point
  -- ... which is precisely, why the self.inherited wrapper exists

  self._legs = 4
end

-- overriding the virtual move function
function TCat:move()
  -- again, calling the base move first
  self.inherited.move()
  print("to be exact, " .. self._name .. " walks on all fours")
end

-- overriding the abstract speak function
function TCat:speak()
  print(self._name .. " meows")
end

local cat = TCat("Paul")

cat:move() --> Paul moves
           --> to be exact, Paul walks on all fours

cat:speak() --> Paul meows

---- Checking, if something is a class or an object

-- there are two functions to check, if anything is any class or object

print("class.isClass()")
print(class.isClass(TAnimal)) --> true
print(class.isClass(TAnimal())) --> false
print(class.isClass(42)) --> false

print("class.isObject()")
print(class.isObject(TAnimal)) --> false
print(class.isObject(TAnimal())) --> true
print(class.isObject(42)) --> false

-- to turning anything into a class (or nil), the "class.of" function can be used

print("class.of")
print(class.of(TAnimal).classname) --> TAnimal
print(class.of(TAnimal()).classname) --> TAnimal
print(class.of(42)) --> nil

---- Checking for inheritance

-- checking the inheritance between classes might seem a bit unconventional
-- it can be checked using the comparison operators
-- classes further down in the inheritance chain are considered "greater"

print("class comparison of different classes")
print(TAnimal == TCat) --> false
print(TAnimal < TCat) --> true
print(TAnimal <= TCat) --> true

print("class comparison with the same class")
print(TAnimal == TAnimal) --> true
print(TAnimal < TAnimal) --> false
print(TAnimal <= TAnimal) --> true

-- anything that isn't a class or object is considered "less" than any class or object

print("class comparison with non-class/object")
print(TAnimal == 42) --> false
print(TAnimal < 42) --> false
print(TAnimal <= 42) --> false

-- if either of the two arguments is an instance instead of a class, its class is used instead

print("instance checking")
-- checking the exact type
print(TCat == TCat()) --> true
-- checking for inheritance
print(TAnimal < TCat()) --> true
-- checking for exact type or inheritance
print(TAnimal <= TCat()) --> true

-- there is one odd case, when checking if a class is a subclass of an instances class
-- if this instance has its own comparison functions, those will have precedence

-- if TAnimal had its own __lt metamethod, that would be called
print(TAnimal() < TCat) --> true
-- this can be fixed by turning the instance into a class manually
print(TAnimal().class < TCat) --> true
-- if the instance might not always be an instance (or class), "class.of" can be used
print(class.of(TAnimal()) < TCat) --> true
