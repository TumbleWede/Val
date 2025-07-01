---
sidebar_position: 1
---
# Introduction
Let's begin by creating some simple logic:
```lua
local num = 20
num = 40
print(num) -- 40
```
In the example above, all we did was create a number, modify it, and print its value.

Now let's do the same thing using Val:
```lua
local num = Val.new(20)
num:set(40)
print(num:get()) -- 40
```
This time, `num` is a state object and not a primitive. To set the value, we simply use the `set` method. To get the value, we just use `get`.

Now, let's try a more legitimate example:
```lua
local label = script.Parent.TextLabel -- assume this exists
local num = 20
label.Text = "Number: " .. num -- Number: 20
num = 40
label.Text = "Number: " .. num -- Number: 40
num = 70
label.Text = "Number: " .. num -- Number: 70
```
One issue with this logic is that we have to manually update `label.Text` every time we change `num` because it is a primitive that cannot be observed.

Now let's try the same thing with Val:
```lua
local label = script.Parent.TextLabel -- assume this exists
local num = Val.new(20)
num:on(function(value)
	label.Text = "Number: " .. num
end, true) -- Number: 20
num:set(40) -- Number: 40
num:set(70) -- Number: 70
```
Now, all we have to do is change the value of `num`, and `label.Text` will automatically update through the `on` method.

Although code this small may not demand the use of a state management library like Val, synchronizing values with displays in large codebases can quickly become messy. Luckily, state management libraries like Val make this synchronization much more manageable.

In the next pages, I will talk more about how to use the features of Val.