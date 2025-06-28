---
sidebar_position: 7
---
# Cloning States
# Usage
Use `Val:copy()` to clone a state:
```lua
local a = Val.new(20)
local b = a:copy()
print(a == b) -- false (implying b is a separate state)
print(a:eq(b)) -- true
a:set(10)
print(b:get()) -- 20
```
However, `Val:copy()` only creates a shallow clone of the state. This means that any object, including internal states, will share the same reference:
```lua
local t1 = Val.scope {
	Val.new(1),
	Val.new(2),
	Val.new(3)
}
local t2 = t1:copy()

t2[1]:die()
print(t1[1]:isdead()) -- true
```
:::note
Val currently does not support deep cloning, but this is subject to change in the future if it becomes a significant limitation.
:::