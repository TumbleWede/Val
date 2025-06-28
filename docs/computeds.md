---
sidebar_position: 3
---
# Computeds
# Usage
This library supports computed states, which are essentially states whose values are derived from dependent states. When a dependent state changes, the computed state will automatically update along with it. This means that you cannot change the value of a computed state manually.

Let's look at a basic example:
```lua
local a = Val.new(3)
local b = Val.new(4)
local h = Val.calc(function(get)
	return math.sqrt(get(a)^2 + get(b)^2)
end)

print(h:get()) -- 5
a:set(6)
b:set(8)
print(h:get()) -- 10
```
In this example, we created a computed that calculates the hypotenuse, `h`, of a right triangle based on the side lengths, `a` and `b`.

We used the `Val.calc` constructor to create the computed, which we passed in a callback function as the argument. This function will return the value of the computed based on the values of the other states we want to use (`a` and `b` in this case). When `a` or `b` updates its value, the callback will be called, thus allowing it to update its value.

Notice how the callback takes in a function called `get` that we use instead of the `Val:get()` method. This special `get` function tells the computed which values it depends on, so if we just used `a:get()` instead of `get(a)`, then `h` would not update if the value of `a` were to change.
:::note
You can call `get(Val<T>)` on the same state multiple times safely; the resulting computed will refer to the value only once, even if you multi-call `get(Val<T>)`.
:::
Let's look at another triangle example below:
```lua
local a, b, c = Val.new(3), Val.new(4), Val.new(5)
local s = Val.calc(function(get)
	return (get(a) + get(b) + get(c)) / 2
end)
-- A = sqrt(s * (s-a) * (s-b) * (s-c)), where s = (a+b+c) / 2
local area = Val.calc(function(get)
	local s2 = get(s)
	return math.sqrt(s2 * (s2 - get(a)) * (s2 - get(b)) * (s2 - get(c)))
end)

print(area:get()) -- 6
a:set(6)
b:set(8)
c:set(10)
print(area:get()) -- 24
```
This example represents Heron's Formula, which calculates the area of a triangle given only its three side lengths. However, this formula needs a variable, `s`, which is equal to half of the sum of the three side lengths. Luckily, we can accomplish this using a computed, so we never have to worry about updating `s` when we need to update one of the side lengths.

Computed states are still considered states, which means that we can also use them in other computeds. In this example, we used the computed `s` inside the computed `area`. This means that when a side length changes, `s` will update which will also update `area`.

:::note
Although chaining computeds like this is possible, there is one drawback, where the final computed may fire multiple times rather than once. In this case, if we set the value of a side length, `s` will update, but since `area` depends on both the side lengths AND `s`, this means that `area` will update twice instead of once. For small calculations like in this example, it's not really a problem, but if you were to have expensive computeds, it would be better to avoid this practice.
:::
# Observer Behavior with Computeds
Observers for computeds behave the exact same as observers for states:
```lua
local s = Val.new(10)
local area = Val.calc(function(get)
	return get(s) ^ 2
end)

s:on(function(new)
	print("Side length set to", new)
end)
area:on(function(new)
	print("Area updated to", new)
end)

s:set(20)
-- Side length set to 20
-- Area updated to 400
```