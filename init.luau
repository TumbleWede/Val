--!strict
--[=[
	@class Val
	A very simple, lightweight state container library.
]=]
local Val = {}
Val.__index = Val

export type Val<T> = typeof(setmetatable({} :: {
	_value: T,
	_listeners: {(T, T, boolean) -> ()},
	_dependents: {any}, -- Type checker gets mad when I try to say Val<any>
	_disconnects: {[any]: () -> ()}?,
	[any]: any
}, Val))

-- Memory safety stuff
local function trueClosure() return true end
local function voidClosure() return function() end end
local function bad<T>(self: Val<T>, key: any): any?
	if key == "isdead" then return trueClosure end
	if key == "die" then return voidClosure end -- Don't punish client for wanting to make sure the value is dead
	error("Attempt to use Val object that has been destroyed.")
	return voidClosure
end
local function badSet()
	error("Attempt to call Val:set() on a computed Val object.")
end
local badMT = {__index = bad}

--[=[
	Constructs a new state
	```luau
	local num = Val.new(20)
	local str = Val.new("Hello, World!")
	local bool = Val.new(true)
	```
]=]
function Val.new<T>(value: T): Val<T>
	return setmetatable({
		_value = value,
		_listeners = {},
		_dependents = {}
	}, Val)
end

--[=[
	Sets the value of the state
	@param value -- the new value of the state
	@param forceSet -- forces the method to execute anyway in case the old value is the same as the new value
	```luau
	local num = Val.new(10)
	num:set(20)
	local str = Val.new("Foo")
	str:set("Bar")
	```
]=]
function Val.set<T>(self: Val<T>, value: T, forceSet: boolean?)
	if value == self._value and not forceSet then return end
	local old = self._value
	self._value = value

	for _, callback in ipairs(self._listeners) do
		callback(value, old, false)
	end
end

--[=[
	@return the value of the state
	```luau
	local num = Val.new(10)
	print(num:get()) -- 10
	```
]=]
function Val.get<T>(self: Val<T>): T
	return self._value
end

--[=[
	Increases state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:add(2) -- 5+2 -> 7
	```
]=]
function Val.add<T>(self: Val<T>, value: any): Val<T>
	self._value += value
	return self
end

--[=[
	Decreases state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:sub(2) -- 5-2 -> 3
	```
]=]
function Val.sub<T>(self: Val<T>, value: any): Val<T>
	self._value /= value
	return self
end

--[=[
	Multiplies state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:mul(2) -- 5*2 -> 10
	```
]=]
function Val.mul<T>(self: Val<T>, value: any): Val<T>
	self._value *= value
	return self
end

--[=[
	Divides state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:div(2) -- 5/2 -> 2.5
	```
]=]
function Val.div<T>(self: Val<T>, value: any): Val<T>
	self._value /= value
	return self
end

--[=[
	Floor divides state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:idiv(2) -- 2 remainder 1 -> 2
	```
]=]
function Val.idiv<T>(self: Val<T>, value: any): Val<T>
	self._value //= value
	return self
end

--[=[
	Applies the modulus of state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:mod(2) -- 2 remainder 1 -> 1
	```
]=]
function Val.mod<T>(self: Val<T>, value: any): Val<T>
	self._value %= value
	return self
end

--[=[
	Exponentiates state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local num = Val.new(5)
	num:pow(2) -- 5^2 -> 25
	```
]=]
function Val.pow<T>(self: Val<T>, value: any): Val<T>
	self._value ^= value
	return self
end

--[=[
	Concatenates state by `value`
	Note: Val does not check if the state's type supports this operation
	@param value
	@return the state's own self (so you can do something like `num:add(10):div(8)`)
	```luau
	local str = Val.new("Hello, ")
	str:cat("World!") -- "Hello, " .. "World!" -> "Hello, World!"
	```
]=]
function Val.cat<T>(self: Val<T>, value: any): Val<T>
	self._value ..= value
	return self
end

--[=[
	Checks if the state's value is equal to the value of `other`
	@param other
	@return boolean
	```luau
	local a = Val.new(10)
	local b = Val.new(10)
	local c = Val.new(20)
	print(a:eq(b)) -- true
	print(a:eq(c)) -- false
	```
]=]
function Val.eq<T, U>(self: Val<T>, other: Val<U>): boolean
	return self._value == other._value
end

--[=[
	Subscribes a callback to be called every time the state's value changes
	@param callback (newValue T, oldValue? T, wasCalledImmediately? boolean) -> ()
	@param callImmediately boolean?
	@return disconnect () -> () -- calling this function will unsubscribe the callback from the state
	```luau
	local num = Val.new(10)
	local disconnect = num:on(function(newValue)
		print("num set to:", newValue)
	end)
	num:set(0) -- num set to: 0
	num:set(20) -- num set to: 20
	disconnect()
	num:set(10) -- no output

	local num = Val.new(10)
	local disconnect = num:on(function(newValue, oldValue, wasCalledImmediately)
		print("was", oldValue, "- now", newValue, "-", wasCalledImmediately)
	end, true) -- was 10 - now 10 - true
	num:set(0) -- was 10 now 0 false
	```
]=]
function Val.on<T>(self: Val<T>, callback: (T, T, boolean) -> (), callImmediately: boolean?): (() -> ())
	table.insert(self._listeners, callback)

	if callImmediately then
		callback(self._value, self._value, true)
	end

	return function()
		if Val.isdead(self) then return end -- In case the state was destroyed
		local index = table.find(self._listeners, callback)
		if index == nil then return end -- You just never know...
		table.remove(self._listeners, index)
	end
end

--[=[
	Destroys the state
	@param shallow -- if true, any states stored inside the current state will be dereferenced rather than destroyed along with the current state
	```luau
	local num = Val.new(10)
	num:set(20)
	num:die()
	num:set(0) -- error

	local bool = Val.new(true)
	bool = bool:die() :: any -- sets bool to nil to ensure that it will be garbage collected

	local foo = Val.new("foo")
	foo.bar = Val.new("bar")
	foo:die() -- also destroys foo.bar

	local yep = Val.new(true)
	local nope = Val.new(false)
	yep.sike = nope
	yep:die(true) -- nope is still alive
	```
]=]
function Val.die<T>(self: Val<T>, shallow: boolean?): nil
	if Val.isdead(self) then return end -- State is already dead (may happen due to coupled states causing memory shenanigans)

	for index = #self._dependents, 1, -1 do
		Val.die(self._dependents[index])
		table.remove(self._dependents, index)
	end
	self._dependents = nil :: any

	table.clear(self._listeners)
	self._listeners = nil :: any

	if self._disconnects then
		for state, unsub in self._disconnects do
			unsub()
			table.remove(state._dependents, table.find(state._dependents, self))
			self._disconnects[state] = nil
		end
	end
	
	self._disconnects = nil
	self["set"] = nil

	-- Destroy value (if it is a state)
	if not shallow then
		local value = self._value :: any
		if value then
			if getmetatable(value :: any) == Val then -- Destroy value if it is a state
				value:die()
			elseif typeof(value) == "table" then -- Destroy state elements if value is a table
				for key, state in value do
					local mt = getmetatable(state :: any)
					if mt ~= Val and mt ~= badMT then continue end
					value[key] = state:die()
				end
			end
		end
	end
	self._value = nil :: any

	-- Destroy custom fields
	for key, value in self :: any do
		if value and getmetatable(value) == Val and not shallow then -- Deep destroy
			value:die()
		end

		self[key] = nil
	end

	setmetatable(self :: any, badMT)
	return nil
end

--[=[
	Note: `Val.isdead(state)` behaves differently from `state:isdead()` to provide the same output, only if the state is dead
	`Val.isdead(state)` checks the metatable of the state while state:isdead() calls a metamethod to return true
	@return whether or not the state is dead
	```luau
	local x = Val.new(true)
	print(x:isdead()) -- false
	print(Val.isdead(x)) -- false
	x:die()
	print(x:isdead()) -- true
	print(Val.isdead(x)) -- true
	print(x:get()) -- error
	```
]=]
function Val.isdead<T>(self: Val<T>): boolean
	return getmetatable(self) :: any == badMT
end

--[=[
	Creates a computed state that automatically updates with its referenced states
	@param eval (get) -> T -- a callback function that should return a new value derived from its dependent states
	@param get (Val<T>) -> T -- inside the eval function, call get(state) instead of state:get() so dependent states are detected
	@return an immutable state (Val:set() is disabled to enforce reactivity)
	Note: If a dependent state is destroyed, then so will the computed
	```luau
	local length = Val.new(10)
	local area = Val.calc(function(get)
		local side = get(length)
		return side * side
	end)
	print(area:get()) -- 10 * 10 -> 100
	length:set(20)
	print(area:get()) -- 20 * 20 -> 400
	```
]=]
function Val.calc<T>(eval: ((Val<any>) -> any) -> T): Val<T>
	local dependencies: {Val<any>} = {}

	local function get<U>(self: Val<U>)
		if not table.find(dependencies, self) then
			table.insert(dependencies, self)
		end

		return self._value
	end

	local self = setmetatable({
		_value = eval(get),
		_listeners = {},
		_dependents = {},
		_disconnects = {},
		set = badSet -- Enforce read-only behavior
	}, Val)

	for _, state in ipairs(dependencies) do
		table.insert(state._dependents, self)
		self._disconnects[state] = state:on(function(value)
			Val.set(self, eval(get))
		end)
	end

	return self
end

--[=[
	Batches a sequence of set calls so that observers are only called after all states are fully set
	@param fn (set) -> T -- a callback function where all the set calls should take place
	@param get (Val<T>) -> T -- inside fn, call set(state) instead of state:set() so that the state change is batched instead of instant
	```luau
	local w = Val.new(6)
	local h = Val.new(5)
	local area = Val.calc(function(get)
		return get(w) * get(h)
	end)
	area:on(function(new)
		print("The area is", new)
	end)

	w:set(8) -- The area is 40
	h:set(3) -- The area is 24

	Val.batch(function(set)
		set(w, 6) -- no output
		set(h, 5) -- no output
	end) -- The area is 30
	```
]=]
function Val.batch(fn: ((Val<any>, any) -> ()) -> ())
	local oldValues: {[Val<any>]: any} = {}

	local function set<T>(self: Val<T>, value: T)
		if oldValues[self] == nil then
			oldValues[self] = self._value
		end

		self._value = value
	end
	fn(set)

	for state, old in oldValues do
		local new = state._value
		for _, callback in ipairs(state._listeners) do
			callback(old, new, false)
		end
	end
end

function Val.scope(values: {[any]: any}?): Val<any>
	local self = Val.new(nil)
	if values == nil then return self end

	for key, value in values do
		self[key] = value
	end

	return self
end

--[=[
	Creates a state with no value, essentially creating a scope manually.
	Equivalent to Val.new(nil)
	@return a state with no value
	```luau
	local rect = Val.none()
	rect.size = Val.new(Vector2.new(2, 5))
	rect.pos = Val.new(Vector2.new(9, -5))
	rect:die() -- also destroys size and pos
	```
]=]
function Val.none(): Val<nil>
	return Val.new(nil)
end

--[=[
	Creates a copy of the state without any subscribed callbacks
	```luau
	local a = Val.new(0)
	a:on(function(value)
		print("set to", value)
	end)
	local b = a:copy()
	a:set(1) -- set to 1
	b:set(2) -- no output
	print(a:get(), b:get()) -- 1, 2
	```
]=]
function Val.copy<T>(self: Val<T>): Val<T>
	return Val.new(self._value)
end

return Val