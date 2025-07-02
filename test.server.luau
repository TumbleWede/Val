--!strict
local TestEZ = require(script.Parent.TestEZ)
TestEZ.TestBootstrap:run {script}

-- Test type annotations
local Val = require(script.Val)

local x: Val.Val<number> = Val.new(0)

local y = x:get()

x:on(function(value)
	local percent = value / 100
end)
