---
sidebar_position: 5
---
# Scopes
# Intro
In Val, scopes are Val objects with no value with the intention of storing other values.

Before we dive into using `Val.scope`, let's first create a Val with fields:
```lua
local rect = Val.new({
	size = Val.new(Vector2.new(5, 3)),
	pos = Val.new(Vector2.new(6, 12))
})
```
In this example, we created a state with fields `size` and `pos`. However, we must call `Val:get` to access these fields (e.g. `rect:get().size`).

We can skip this step by adding the fields directly inside the state object rather than inside the state's value:
```lua
local rect = Val.none() -- alias for Val.new(nil)
rect.size = Val.new(Vector2.new(5, 3))
rect.pos = Val.new(Vector2.new(6, 12))
```
This time, we can directly access `size` and `pos` (e.g. `rect.size`) without the need of `rect:get()`. Val does not stop you from modifying or accessing keys inside any states (unless the state is dead), so we can get away with this safely as long as we don't override any internal/private fields.
:::warning
Avoid adding custom fields with the following names: `_value`, `_listeners`, `_dependents`, `_disconnects`, `_eval`, and `set`
:::
# Using `Val.scope`
Now let's do the same thing using `Val.scope`:
```lua
local rect = Val.scope {
	size = Val.new(Vector2.new(5, 3)),
	pos = Val.new(Vector2.new(6, 12))
}
```
This code example will give us the same result as the previous example: a valueless state with custom fields. The benefit of using `Val.scope` instead of `Val.none()` is that you can store your custom fields in a table argument.

For dictionaries, using `Val.scope` or `Val.none()` is based on your preference, but you will absolutely need to use `Val.scope` for arrays:
```lua
local nums = Val.scope {
	Val.new(1),
	Val.new(2),
	Val.new(3),
	Val.new(4)
}
```
In this example, the list of states will be directly inside `nums` rather than inside its value.
# Iteration
You can safely iterate through a scope's keys without iterating through the state's private fields:
```lua
local t = Val.scope {
	a = Val.new(1),
	b = Val.new(2),
	c = Val.new(3)
}

for i, v in t do
	print(i, v:get())
end
-- a 1
-- b 2
-- c 3
```
Because we used generic iteration, the for loop utilized the scope's iteration metamethod which will ensure that private keys will not be iterated through.

Now let's do the same thing for an array:
```lua
local t = Val.scope {
	Val.new(7),
	Val.new(8),
	Val.new(9)
}

for i, v in ipairs(t) do
	print(i, v:get())
end
-- 1 7
-- 2 8
-- 3 9
```
In this example, we used `ipairs` instead of generic iteration to iterate through the indices. Although generic iteration could have produced the exact same result, `ipairs` is faster.
:::tip
Always use `ipairs` over generic iteration if you only need to use the index-value pairs and not key-value pairs.
:::
:::danger
Using `pairs` will iterate through the state's private keys, which can lead to undefined behavior. Always use either `ipairs` or generic iteration for scopes.
:::
Now let's do an example of combining numeric and string keys in the scope. In this case, there is a significant difference in each iteration method:
```lua
local t = Val.scope {
	a = Val.new(1),
	b = Val.new(2),
	c = Val.new(3),
	Val.new(7),
	Val.new(8),
	Val.new(9)
}

-- generic iteration
for i, v in t do
	print(i, v:get())
end
-- 1 7
-- 2 8
-- 3 9
-- a 1
-- b 2
-- c 3

-- ipairs
for i, v in ipairs(t) do
	print(i, v:get())
end
-- 1 7
-- 2 8
-- 3 9

-- pairs (why you should avoid this)
for i, v in pairs(t) do
	print(i, v:get())
end
-- 1 7
-- 2 8
-- 3 9
-- a 1
-- error: attempt to call missing method 'get' of table
```
In this example, all three iterator methods produced a different result:
- Generic iteration printed every custom key-value/index-value pair
- `ipairs` only printed every index-value pair
- `pairs` resulted in an error after the for loop tried to access a private key and assumed it was a state
# Observer Behavior with Scopes
:::note
Val currently does not have special observer behavior for scopes, but this is subject to change in the future if it becomes a significant limitation.
:::
Observers do not work directly on scopes because they listen to the value of the scope, which is typically just `nil`.
However, you can simply overcome this by adding observers to the fields and not the scope:
```lua
local rect = Val.scope {
	pos = Val.new(Vector2.new(2, 6)),
	size = Val.new(Vector2.new(4, 3))
}

local onChange = function()
	print("Rectangle of size", rect.size:get(), "located at", rect.pos:get())
end
rect.pos:on(onChange)
rect.size:on(onChange, true) -- Rectangle of size 4, 3 located at 2, 6
rect.pos:set(Vector2.new(5, 10)) -- Rectangle of size 4, 3 located at 5, 10
rect.size:set(Vector2.new(1, 2)) -- Rectangle of size 1, 2 located at 5, 10
```
When working with an unknown list of index-value pairs, we can use a table to keep track of observers for each index:
```lua
local list = Val.scope {
	Val.new(1),
	Val.new(2),
	Val.new(3)
}

local onChange = function()
	local sum = 0
	for i, v in ipairs(list) do
		sum += v:get()
	end
	print("The sum of the values of the list is", sum)
end

local observers = {}
for i, v in ipairs(list) do
	observers[i] = v:on(onChange)
end
list[1]:set(list[1]:get(), true) -- Force update the value to immediately call the observer once
-- The sum of the values of the list is 6
list[2]:set(10) -- The sum of the values of the list is 14

-- Destroy scope
for i, v in ipairs(observers) do
	v()
end
observers = nil -- Also dereferences the disconnects
list:die() -- Also destroys the three values
```
:::tip
Remember that you only need to use Val when you care about observing/reacting to value changes. If you have a field that you don't need to actively listen to, it does not need to be a Val object. You also only really need to use a scope rather than a regular table if/when you plan on destroying all the internal states at once for memory management purposes.
:::