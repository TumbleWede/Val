---
sidebar_position: 6
---
# Destroying States
# Usage
To destroy a state, simply use `Val:die()`. To check if a state has been destroyed, call either `Val:isdead()` or `Val.isdead(Val<T>)` (all methods can be called as static such as `Val.set(Val<T>, T)`):
```lua
local x = Val.new(20)
x:set(30)
print(x:isdead()) -- false
x:die()
x:set(40) -- error
print(x:isdead()) -- true
```
After a value has been destroyed, you can no longer use its methods other than `Val:die()` and `Val:isdead()`. All of its contents will be removed, and trying to access any fields may result in an error.

If a computed is dependent on a state that has been destroyed, then the computed will also be destroyed:
```lua
local side = Val.new(5)
local area = Val.calc(function(get)
	return get(side) ^ 2
end)

print(side:isdead()) -- false
print(area:isdead()) -- false
side:die()
print(side:isdead()) -- true
print(area:isdead()) -- true
```
:::tip
`Val:Destroy()` is an alias for `Val:die()` for better compatibility with cleanup libraries like [Janitor](https://howmanysmall.github.io/Janitor/)
:::
# Destroying Scopes
By default, all states inside the dying state will be destroyed along with the state. Alternatively, you can call `Val:die(true)`, where the `true` argument indicates that all internal states will be dereferenced rather than destroyed:
```lua
local t1 = Val.new({
	Val.new(1),
	Val.new(2),
	Val.new(3)
})
t1:die() -- 1, 2, and 3 states will also be destroyed

local t2 = Val.scope {
	Val.new(1),
	Val.new(2),
	Val.new(3),
	a = Val.new(1),
	b = Val.new(2),
	c = Val.new(3),
}
t2:die() -- All six states will be destroyed

local x = Val.new(1)
local t3 = Val.scope {
	a = x,
	b = Val.new(2),
	c = Val.new(3),
}
t3:die() -- a, b, and c will be destroyed.
print(x:isdead()) -- true

local y = Val.new(1)
local t4 = Val.scope {
	a = y,
	b = Val.new(2),
	c = Val.new(3),
}
t4:die(true) -- a, b, and c will be dereferenced but alive.
-- y will remain alive, but the values of t4.b and t4.c will be garbage collected
```
:::note
`Val:isdead()` and `Val.isdead(Val<T>)` return the same result, but the two behave differently if the state is dead.
- `Val.isdead(Val<T>)` will compare the metatable of the state to the metatable of a dead state
- `Val:isdead()` is an exception for accessing methods of a dead state, in which the `__index` metamethod will refer to a function that returns true.

If the state is alive, `Val:isdead()` will refer to `Val.isdead(self)`.
:::