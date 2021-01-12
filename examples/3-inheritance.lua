local class = require "class"

---- Creating a base class Animal with virtual and abstract methods

-- Classes do not have to inherit.
-- Likewise, Object is NOT the ultimate base class of all other classes.
local Animal = class("Animal")

function Animal:create(name)
  self._name = name
end

-- By virtue of the way Lua works, all methods are effectively "virtual".
function Animal:move()
  print(self._name .. " moves")
end

-- Calling Animal:speak() will raise an error.
Animal:makeAbstract "speak"

local animal = Animal("Peter")
animal:move() --> Peter moves

local _, err = pcall(function()
  animal:speak() --> abstract call error, see below
end)

print(err) --> [...]: attempt to call abstract Animal:speak

---- Creating a subclass Cat, overriding existing methods

-- Inheritance can be achieved by simply passing the base class as a second parameter.
-- Additionally, the base class is also returned and captured in a variable "super".
-- This way the base class can be referenced without mentioning it explicitly.
-- Multiple inheritance is NOT supported currently, but may be introduced at some point.
local Cat, super = class("Cat", Animal)

-- Overriding the existing constructor.
function Cat:create(...)
  -- Usually we also want to call the constructor of the base class.
  -- The "super" defined above comes in handy here.
  super.create(self, ...)
  -- WARNING --
  -- Using self.baseclass instead, will always be the immediate base class of the instance.
  -- The moment a third layer is introduced into the class hierachy, this will cause infinite recursion.

  self._legs = 4
end

-- Overriding the virtual move function.
function Cat:move()
  -- Again, calling the base move first using "super".
  super.move(self)
  print("to be exact, " .. self._name .. " walks on all fours")
end

-- Overriding the abstract speak function.
function Cat:speak()
  print(self._name .. " meows")
end

local cat = Cat("Paul")

cat:move() --> Paul moves
           --> to be exact, Paul walks on all fours

cat:speak() --> Paul meows

---- Checking, if something is a class or an object

-- There are two functions to check, if anything is any class or object.

print("class.isClass()")
print(class.isClass(Animal)) --> true
print(class.isClass(Animal())) --> false
print(class.isClass(42)) --> false

print("class.isObject()")
print(class.isObject(Animal)) --> false
print(class.isObject(Animal())) --> true
print(class.isObject(42)) --> false

-- To turning anything into a class (or nil), the "class.of" function can be used.

print("class.of()")
print(class.of(Animal).classname) --> Animal
print(class.of(Animal()).classname) --> Animal
print(class.of(42)) --> nil

---- Checking for inheritance

-- Checking the inheritance between classes might seem a bit unconventional.
-- It can be checked using the comparison operators.
-- Classes further down in the same inheritance chain are considered "greater".

print("class comparison of different classes")
print(Animal == Cat) --> false
print(Animal < Cat) --> true
print(Animal <= Cat) --> true

print("class comparison with the same class")
print(Animal == Animal) --> true
print(Animal < Animal) --> false
print(Animal <= Animal) --> true

-- Anything that isn't a class or object is considered "less" than any class or object.

print("class comparison with non-class/object")
print(Animal == 42) --> false
print(Animal < 42) --> false
print(Animal <= 42) --> false

-- If either of the two arguments is an instance instead of a class, its class is used instead.

print("instance checking")
-- Checking the exact type.
print(Cat == Cat()) --> true
-- Checking for inheritance.
print(Animal < Cat()) --> true
-- Checking for exact type or inheritance.
print(Animal <= Cat()) --> true

-- There is one odd case, when checking if a class is a subclass of an instances class.
-- If this instance has its own comparison functions, those will be preferred.

-- If Animal had its own __lt metamethod, that would be called.
print(Animal() < Cat) --> true
-- This can be fixed by turning the instance into a class manually.
print(Animal().class < Cat) --> true
-- If the instance might not always be an instance (or class), "class.of" can be used.
print(class.of(Animal()) < Cat) --> true
