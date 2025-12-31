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

			local n = Val.new(2)
			n:add(3):clamp(2, 4)
			expect(n:get()).to.equal(4)
			expect(n:clamp(3, 5):get()).to.equal(4)
			expect(n:clamp(10, 12):get()).to.equal(10)
			expect(n:max(1):get()).to.equal(10)
			expect(n:min(5):get()).to.equal(5)
			expect(n:min(-1, 2, 7):get()).to.equal(-1)
			expect(n:max(-5, 5, 7, 10):get()).to.equal(10)
			expect(n:max(5):get()).to.equal(10)
			expect(n:min(20):get()).to.equal(10)

			n:add(0.5):floor()
			expect(n:get()).to.equal(10)
			expect(n:add(1.2):floor():get()).to.equal(11)
			expect(n:add(0.1):ceil():get()).to.equal(12)
			expect(n:add(0.3):round():get()).to.equal(12)
			expect(n:add(0.7):round():get()).to.equal(13)
			n:set(-2)
			expect(n:abs():get()).to.equal(2)
			expect(n:abs():get()).to.equal(2)
			expect(n:lerp(3, 0.5):get()).to.equal(2.5)
			expect(n:lerp(1, 1):get()).to.equal(1)
			expect(n:lerp(5, 0.25):get()).to.equal(2)
			expect(n:snap(3):get()).to.equal(3)
			expect(n:add(0.5):snap(1):get()).to.equal(4)
			expect(n:add(0.2):snap(0.5):get()).to.equal(4)
			expect(n:add(0.3):snap(0.5):get()).to.equal(4.5)
			expect(n:add(0.2):snap(0.5):get()).to.equal(4.5)
			expect(n:set(2.718):snap(0.1):get()).to.equal(2.7)
			expect(n:set(2.718):snap(0.01):get()).to.equal(2.72)
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

			local count = 0
			local d = x:on(function()
				count += 1
			end)
			x:set(math.pi)
			expect(count).to.equal(1)
			x:set(math.pi)
			expect(count).to.equal(1)
			x:set(math.pi, true)
			expect(count).to.equal(2)
			x:add(3)
			expect(count).to.equal(3)
			x:sub(4)
			expect(count).to.equal(4)
			x:mul(5)
			expect(count).to.equal(5)
			x:div(2)
			expect(count).to.equal(6)
			x:idiv(2)
			expect(count).to.equal(7)
			x:mod(2)
			expect(count).to.equal(8)
			x:set(2)
			x:pow(2)
			expect(count).to.equal(10)

			x:set(math.pi)
			count = 0
			x:floor()
			expect(count).to.equal(1)

			x:set(math.pi)
			count = 0
			x:ceil()
			expect(count).to.equal(1)

			x:set(math.pi)
			count = 0
			x:round()
			expect(count).to.equal(1)

			x:set(-2)
			count = 0
			x:abs()
			expect(count).to.equal(1)

			x:set(0)
			count = 0
			x:lerp(1, 0.5)
			expect(count).to.equal(1)

			x:set(math.pi)
			count = 0
			x:snap(1)
			expect(count).to.equal(1)

			x:set(2)
			count = 0
			x:clamp(3, 4)
			expect(count).to.equal(1)

			d()
			x:die()

			local s = Val.new("a")
			local updated = false
			d = s:on(function()
				updated = true
			end)

			s:cat("b")
			expect(updated).to.equal(true)
			d()
			s:die()

			local b = Val.new(false)
			updated = false
			d = b:on(function()
				updated = true
			end)
			b:flip()
			expect(updated).to.equal(true)
			d()
			b:die()

			x = Val.new(0)
			count = 0
			d = x:on(function()
				count += 1
			end)
			x:set(0, true)
			expect(count).to.equal(1)
			x:add(0, true)
			expect(count).to.equal(2)
			x:sub(0, true)
			expect(count).to.equal(3)
			x:mul(0, true)
			expect(count).to.equal(4)
			x:div(1, true)
			expect(count).to.equal(5)
			x:idiv(1, true)
			expect(count).to.equal(6)
			x:mod(0, true)
			expect(count).to.equal(7)
			x:pow(1, true)
			expect(count).to.equal(8)
			x:clamp(0, 1, true)
			expect(count).to.equal(9)
			x:abs(0, true)
			expect(count).to.equal(10)
			x:floor(0, true)
			expect(count).to.equal(11)
			x:ceil(0, true)
			expect(count).to.equal(12)
			x:round(0, true)
			expect(count).to.equal(13)
			x:snap(1, true)
			expect(count).to.equal(14)
			x:lerp(1, 0, true)
			expect(count).to.equal(15)

			d()
			x:die()
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

			local z = Val.new(2)
			z:Destroy()
			expect(z:isdead()).to.equal(true)
		end)
	end)

	describe("advanced states", function()
		it("should support iteration", function()
			local t = Val.scope {1, 2, 3, 4, 5, 6}

			for i, v in t do
				expect(i).never.to.equal("_value")
				expect(i).never.to.equal("_listeners")
				expect(i).never.to.equal("_dependents")
				expect(i).never.to.equal("_disconnects")
				expect(i).never.to.equal("_eval")
				expect(i).never.to.equal("set")
			end

			t.bad = "bad"

			for i, v in ipairs(t) do
				expect(i).never.to.equal("_value")
				expect(i).never.to.equal("_listeners")
				expect(i).never.to.equal("_dependents")
				expect(i).never.to.equal("_disconnects")
				expect(i).never.to.equal("_eval")
				expect(i).never.to.equal("set")
				expect(i).never.to.equal("bad")
			end

			expect(#t).to.equal(6)
			t:die()
		end)
	end)

	describe("cloning states", function()
		it("should clone basic states", function()
			local x = Val.new(2)
			local y = x:copy()
			local z = x
			expect(x:eq(y)).to.equal(true)
			expect(x == z).to.equal(true)
			expect(x == y).to.equal(false)
		end)

		it("should clone states with custom fields", function()
			local x = Val.new(2)
			x.Test = true
			local y = x:copy()
			expect(y.Test).to.equal(true)
		end)

		it("should clone computeds", function()
			local a = Val.new(3)
			local b = Val.new(4)
			local h = Val.calc(function(get)
				return math.sqrt(get(a) ^ 2 + get(b) ^ 2)
			end)
			expect(h:get()).to.equal(5)

			local h2 = h:copy()
			expect(h:eq(h2)).to.equal(true)
			expect(h == h2).to.equal(false)
			local c = a:copy()
			expect(#c._dependents).to.equal(0)
			c = c:die()
			expect(h:isdead()).to.equal(false)
			expect(h2:isdead()).to.equal(false)
			a:die()
			b:die()
			expect(h:isdead()).to.equal(true)
			expect(h2:isdead()).to.equal(true)
		end)

		it("should clone scopes", function()
			local x = Val.none()
			x.a = Val.new(20)
			local c = Val.calc(function(get)
				return get(x.a) ^ 2
			end)
			expect(c:get()).to.equal(400)
			x.a:set(10)
			expect(c:get()).to.equal(100)
			local y = x:copy()
			expect(y.a == x.a).to.equal(true)
			expect(y == x).to.equal(false)
			y.a:set(20)
			expect(c:get()).to.equal(400)
			y.a = y.a:copy()
			y.a:set(10)
			expect(c:get()).to.equal(400)

			local v = Val.scope {
				Val.new(Vector2.new(-1, -1)),
				Val.new(Vector2.new(-1, 1)),
				Val.new(Vector2.new(1, -1)),
				Val.new(Vector2.new(1, 1))
			}

			local v2 = v:copy()
			for i, vec in ipairs(v) do
				expect(vec == v2[i]).to.equal(true)
			end
		end)
	end)
end
