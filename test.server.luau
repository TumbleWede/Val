local TestEZ = require(script.Parent.TestEZ)
TestEZ.TestBootstrap:run {script}

-- Stress test
local Val = require(script.Val)

local function runBenchmark(name: string, fn: () -> ())
	local start = os.clock()
	fn()
	local elapsed = os.clock() - start
	print(string.format("%-25s: %.6f sec", name, elapsed))
end

local ITERATIONS = 100000

-- Baseline (raw table)
runBenchmark("Raw table set", function()
	local t = { value = 0 }
	for i = 1, ITERATIONS do
		t.value = i
	end
end)

runBenchmark("Raw table get", function()
	local t = { value = 0 }
	for i = 1, ITERATIONS do
		local _ = t.value
	end
end)

-- Val.set
runBenchmark("Val.set", function()
	local state = Val.new(0)
	for i = 1, ITERATIONS do
		state:set(i)
	end
end)

-- Val.get
runBenchmark("Val.get", function()
	local state = Val.new(0)
	for i = 1, ITERATIONS do
		local _ = state:get()
	end
end)

-- Val.on
runBenchmark("Val.on", function()
	local state = Val.new(0)
	state:on(function() end)
	for i = 1, ITERATIONS do
		state:set(i)
	end
end)

-- Val.calc
runBenchmark("Val.calc", function()
	local a = Val.new(1)
	local c = Val.calc(function(get)
		return get(a)
	end)

	for i = 1, ITERATIONS do
		a:set(i)
	end
end)

-- Val.batch
runBenchmark("Val.batch", function()
	local a = Val.new(1)
	Val.batch(function(set)
		for i = 1, ITERATIONS do
			set(a, i)
		end
	end)
end)