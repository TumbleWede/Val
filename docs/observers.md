---
sidebar_position: 2
---
# Observers
# Usage
Observers are event listeners that are called whenever the state changes its value:
```lua
local x = Val.new(2)
local disconnect = x:on(function(newValue, oldValue, wasCalledImmediately)
	print(newValue, oldValue, wasCalledImmediately)
end, true) -- 2 2 true
x:set(4) -- 4 2 false
x:set(8) -- 8 4 false
x:set(8) -- no output because value did not change
x:set(8, true) -- 8 8 false
disconnect()
x:set(16) -- no output
```
We created an observer by calling the `Val:on` method, which takes in a callback function and an optional boolean.

The callback function takes in three optional values:
- `newValue` - the state's newly updated value
- `oldValue` - the state's previous value
- `wasCalledImmediately` - if the callback was called immediately

In most cases, you will only need `newValue`.

The second optional parameter, if set to `true`, indicates that we want to call the observer immediately. If `false` or `nil`, the observer will not be called until the next state update.

The `Val:on` method returns a disconnect callback. When we no longer need to listen to a value, we can call this disconnect. In the example above, our observer would display any changes of the value of `x`, but this observer is destroyed after we called `disconnect()`

In the example above, we used `Val:set` with a second optional boolean parameter that, when `true`, would cause the method to call its observers even if the value did not actually change.

:::tip
For type safety, you may need to indicate the types of `newValue` and `oldValue` due to Luau's type solver being unable to recognize the state's type:
```lua
local disconnect = x:on(function(newValue: number, oldValue: number, wasCalledImmediately)
	print(newValue, oldValue, wasCalledImmediately)
end, true) -- 2 2 true
```
:::