---
sidebar_position: 8
---
# Batching
Val supports batching, where we can set multiple states in a batch that will only call observers after all the values have been set.

Let's look at a basic example of setting a state without batching:
```lua
local x = Val.new(2)
x:on(function(value)
	print("x set to", value)
end)
x:set(3) -- x set to 3
x:set(4) -- x set to 4
x:set(5) -- x set to 5
```
In this case, the observer will be called after each set. Now let's do the same thing but with batching:
```lua
local x = Val.new(2)
x:on(function(value)
	print("x set to", value)
end)

Val.batch(function(set)
	set(x, 3) -- no output
	set(x, 4) -- no output
	set(x, 5) -- no output
end) -- x set to 5
```
This time, setting the value of x will not call the observer until after the batch is done. This means that the observer will only be called once instead of three times.

The `Val.batch` function took in a callback function as the argument, which took in a set function. The `set(Val<T>, T)` function allows us to set the value of the state without immediately calling the observer. If `Val:set` were to be used inside the batch callback, then the observer would immediately be called.

:::note
- You cannot use any of the assignment operator methods inside the batch, as just like `Val:set`, they would immediately call the observer inside the batch. You would have to set the value manually, so `a:add(b)` would look like `set(a, a:get() + b)`
- Computeds cannot be batched because of their reliance on observers. As mentioned previously about redundant updates when chaining computeds, there is not a way to solve it with batching in Val.
:::