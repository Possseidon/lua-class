local class = require "class"

---- Creating a base class Animal with virtual and abstract methods

-- classes do not have to inherit
-- likewise, Object is NOT the ultimate base class of all other classes
local Animal = class("Animal")

function Animal:create(name)
  self._name = name
end

-- by virtue of the way Lua works, all methods are "virtual"
function Animal:move()
  print(self._name .. " moves")
end

-- calling Animal:speak will raise an error
Animal:makeAbstract "speak"

local _, err = pcall(function()
  local animal = Animal("Peter")
  animal:move() --> Peter moves
  animal:speak() --> abstract call error, see below
end)

print(err) --> [...]: attempt to call abstract Animal:speak

---- Creating a subclass Cat, overriding existing methods

-- inheritance can be achieved by simply passing the base class as a second parameter
-- additionally, the base class is also returned and captured in a variable "super"
-- this way the base class can be referenced without mentioning it explicitly
-- multiple inheritance is NOT supported currently, but may be introduced at some point
local Cat, super = class("Cat", Animal)

-- overriding the existing constructor
function Cat:create(...)
  -- usually we also want to call the constructor of the base class
  -- the "super" defined above comes in handy here
  super.create(self, ...)
  -- WARNING --
  -- using self.baseclass instead, will always be the immediate base class of the instance
  -- the moment a third layer is introduced into the class hierachy, this will cause infinite recursion

  self._legs = 4
end

-- overriding the virtual move function
function Cat:move()
  -- again, calling the base move first
  super.move(self)
  print("to be exact, " .. self._name .. " walks on all fours")
end

-- overriding the abstract speak function
function Cat:speak()
  print(self._name .. " meows")
end

local cat = Cat("Paul")

cat:move() --> Paul moves
           --> to be exact, Paul walks on all fours

cat:speak() --> Paul meows

---- Checking, if something is a class or an object

-- there are two functions to check, if anything is any class or object

print("class.isClass()")
print(class.isClass(Animal)) --> true
print(class.isClass(Animal())) --> false
print(class.isClass(42)) --> false

print("class.isObject()")
print(class.isObject(Animal)) --> false
print(class.isObject(Animal())) --> true
print(class.isObject(42)) --> false

-- to turning anything into a class (or nil), the "class.of" function can be used

print("class.of()")
print(class.of(Animal).classname) --> Animal
print(class.of(Animal()).classname) --> Animal
print(class.of(42)) --> nil

---- Checking for inheritance

-- checking the inheritance between classes might seem a bit unconventional
-- it can be checked using the comparison operators
-- classes further down in the inheritance chain are considered "greater"

print("class comparison of different classes")
print(Animal == Cat) --> false
print(Animal < Cat) --> true
print(Animal <= Cat) --> true

print("class comparison with the same class")
print(Animal == Animal) --> true
print(Animal < Animal) --> false
print(Animal <= Animal) --> true

-- anything that isn't a class or object is considered "less" than any class or object

print("class comparison with non-class/object")
print(Animal == 42) --> false
print(Animal < 42) --> false
print(Animal <= 42) --> false

-- if either of the two arguments is an instance instead of a class, its class is used instead

print("instance checking")
-- checking the exact type
print(Cat == Cat()) --> true
-- checking for inheritance
print(Animal < Cat()) --> true
-- checking for exact type or inheritance
print(Animal <= Cat()) --> true

-- there is one odd case, when checking if a class is a subclass of an instances class
-- if this instance has its own comparison functions, those will have precedence

-- if Animal had its own __lt metamethod, that would be called
print(Animal() < Cat) --> true
-- this can be fixed by turning the instance into a class manually
print(Animal().class < Cat) --> true
-- if the instance might not always be an instance (or class), "class.of" can be used
print(class.of(Animal()) < Cat) --> true
