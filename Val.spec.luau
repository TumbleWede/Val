return function()
	local Val = require(script.Parent.Val)
	
	describe("simple states", function()
		it("should create a state with a value", function()
			local x = Val.new(20)
			expect(x:get()).to.equal(20)

			local str = Val.new("Hello, World!")
			expect(str:get()).to.equal("Hello, World!")

			local bool = Val.new(true)
			expect(bool:get()).to.equal(true)

			local n = Val.none()
			expect(n:get()).never.to.be.ok()
		end)

		it("should change values", function()
			local x = Val.new(20)
			x:set(40)
			expect(x:get()).to.equal(40)
			x:add(20)
			expect(x:get()).to.equal(60)
			x:sub(20)
			expect(x:get()).to.equal(40)
			x:mul(2)
			expect(x:get()).to.equal(80)
			x:div(2)
			expect(x:get()).to.equal(40)
			x:add(20):sub(20):mul(2):div(2)
			expect(x:get()).to.equal(40)
			
			local y = Val.new(5)
			y:idiv(2)
			expect(y:get()).to.equal(2)
			expect(y:add(3):idiv(2):get()).to.equal(2)
			expect(y:add(3):mod(2):get()).to.equal(1)
			expect(y:add(5):mod(2):get()).to.equal(0)
			
			local z = Val.new(2)
			expect(z:pow(3):get()).to.equal(8)
			expect(z:sub(5):pow(2):get()).to.equal(9)

			local s = Val.new("Hello,")
			s:cat(" World!")
			expect(s:get()).to.equal("Hello, World!")

			local b = Val.new(true)
			expect(b:flip():get()).to.equal(false)
			expect(b:flip():flip():get()).to.equal(false)
			expect(b:flip():flip():flip():get()).to.equal(true)
		end)

		it("should be comparable", function()
			local s = Val.new("Hello,")
			s:cat(" World!")
			expect(s:eq(Val.new("Hello, World!"))).to.equal(true)

			local t1 = Val.new(true)
			local t2 = Val.new(true)
			local f = Val.new(false)
			expect(t1:eq(t2)).to.equal(true)
			expect(t1:eq(f)).to.equal(false)

			local a = Val.new(1)
			local b = Val.new(1)
			local c = Val.new(2)

			expect(a:eq(b)).to.equal(true)
			expect(b:eq(a)).to.equal(true)
			expect(a:eq(c)).to.equal(false)
			expect(c:eq(a)).to.equal(false)

			expect(a:lt(b)).to.equal(false)
			expect(b:lt(a)).to.equal(false)
			expect(a:lt(c)).to.equal(true)
			expect(c:lt(a)).to.equal(false)

			expect(a:gt(b)).to.equal(false)
			expect(b:gt(a)).to.equal(false)
			expect(a:gt(c)).to.equal(false)
			expect(c:gt(a)).to.equal(true)

			expect(a:le(b)).to.equal(true)
			expect(b:le(a)).to.equal(true)
			expect(a:le(c)).to.equal(true)
			expect(c:le(a)).to.equal(false)

			expect(a:ge(b)).to.equal(true)
			expect(b:ge(a)).to.equal(true)
			expect(a:ge(c)).to.equal(false)
			expect(c:ge(a)).to.equal(true)
		end)

		it("should support observers", function()
			local x = Val.new(10)
			local new, old, instant
			local disconnect = x:on(function(newValue, oldValue, immediate)
				new = newValue
				old = oldValue
				instant = immediate
			end, true)
			expect(new).to.equal(10)
			expect(old).to.equal(10)
			expect(instant).to.equal(true)
			x:set(20)
			expect(new).to.equal(20)
			expect(old).to.equal(10)
			expect(instant).to.equal(false)
			x:set(30)
			expect(new).to.equal(30)
			expect(old).to.equal(20)
			expect(instant).to.equal(false)
			disconnect()
			x:set(10)
			expect(new).to.equal(30)
			expect(old).to.equal(20)
			expect(instant).to.equal(false)
		end)

		it("should destroy itself when killed", function()
			local x = Val.new(2)
			expect(x:isdead()).to.equal(false)
			expect(Val.isdead(x)).to.equal(false)
			x:die()
			expect(function()
				x:die()
			end).never.to.throw()
			expect(function()
				x:set(6)
			end).to.throw()
			expect(x:isdead()).to.equal(true)
			expect(Val.isdead(x)).to.equal(true)

			local y = Val.new(true)
			expect(function()
				y:die(true)
			end).never.to.throw()

			local a = Val.new(10)
			local disconnect = a:on(function() end)
			a:die()
			expect(function()
				disconnect()
			end).never.to.throw()
		end)
	end)

	describe("advanced states", function()
		it("should support states within states", function()
			-- Scope array example
			local waypoints = Val.scope {
				Val.new(Vector3.new(2, 6, -3)),
				Val.new(Vector3.new(9, -4, 8)),
				Val.new(Vector3.new(-5, 8, 2)),
				Val.new(Vector3.new(-7, 2, -1)),
			}

			waypoints:die() -- kills all the Vector3 states inside the scope
		end)

		it("should support iteration", function()
			local t = Val.scope {1, 2, 3, 4, 5, 6}

			for i, v in t do
				expect(i).never.to.equal("_value")
				expect(i).never.to.equal("_listeners")
				expect(i).never.to.equal("_dependents")
				expect(i).never.to.equal("_disconnects")
				expect(i).never.to.equal("set")
			end

			t.bad = "bad"

			for i, v in ipairs(t) do
				expect(i).never.to.equal("_value")
				expect(i).never.to.equal("_listeners")
				expect(i).never.to.equal("_dependents")
				expect(i).never.to.equal("_disconnects")
				expect(i).never.to.equal("set")
				expect(i).never.to.equal("bad")
			end

			expect(#t).to.equal(6)
			t:die()
			for i, v in t do
				print(i, v)
			end
		end)
	end)
end
