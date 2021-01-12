# lua-class

Yet another class library for Lua, because there aren't enough already. ¯\\\_(ツ)\_/¯

## Usage

It follows a small example showing its basic usage.

Personally I use PascalCase for my class names, which is fairly common in other languages as well. Of course, feel free to use whichever convention suits you best.

```lua
local class = require "class"

-- Creating the class:

local Value = class("Value")

function Value:create(value)
  self._value = value
end

function Value:get()
  return self._value
end

function Value:set(value)
  self._value = value
end

-- Creating an instance:

local value = Value("Hello World!")

print(value:get()) --> Hello World!

value:set("How are you?")

print(value:get()) --> How are you?
```

A class `Value` with simple `create` (constructor), `get` and `set` methods.

I generally put each class in its own file and name the file accordingly, similar to how [Object.lua](lib/Object.lua) and [Event.lua](lib/Event.lua) look.

---

## Library

### [class.lua](lib/class.lua)

- The core library.
- Can be used standalone.
- Supports creation of classes and inheritance.

### [Object.lua](lib/Object.lua)

- Can be used as a base class.
- Enables the use of properties using custom `get` and `set` functions.
- Comes with useful helper functions to create properties with common `get` and `set` functions.

### [Event.lua](lib/Event.lua)

- Provides a simple multicast event.
- Handlers can be added and removed with the `add` and `remove` methods.
- Calls all handlers in the order they were added, when the event is called.

---

## Examples

### [1-simple.lua](examples/1-simple.lua)

- Shows basic usage.
- A simple class `Value` with `Value:get()` and `Value:set(value)` methods.

### [2-constructor.lua](examples/2-constructor.lua)

- Customize instance creation with a `MyClass:create()` method.
- Creating instance fields.

### [3-inheritance.lua](examples/3-inheritance.lua)

- Creating a base class `Animal` and a subclass `Cat`.
- Virtual and abstract methods.
- Calling base methods in a derived method.
- Checking if something is a class or an object using `class.isClass()` and `class.isObject()`.
- Safely turning any value into its class (or `nil`) using `class.of()`.
- Checking the inheritance hierachy of classes and objects using the comparison operators.

### [4-customize-inheritance.lua](examples/4-customize-inheritance.lua)

- Customize what happens, when a certain class is inherited from.
