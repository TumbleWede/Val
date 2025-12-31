--!strict
local TestEZ = require(script.Parent.TestEZ) :: any
TestEZ.TestBootstrap:run {script}

-- Test type annotations
local Val = require(script.Val)

local x = Val.new(2)

local y = x:get()

x:on(function(value, old, wasCalledImmediately)
	local percent = value / 100
end)

Val.batch(function(set)
	set(x, 3)
end)