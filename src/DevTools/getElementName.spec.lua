return function()
	local getElementName = require(script.Parent.getElementName)

	local createElement = require(script.Parent.Parent.createElement)
	local Component = require(script.Parent.Parent.Component)

	it("returns the stateful component name", function()
		local TestComponent = Component:extend("TestComponent")
		function TestComponent:render()
			return nil
		end
		expect(getElementName(createElement(TestComponent))).to.equal("TestComponent")
	end)

	it("returns the function component name", function()
		local function TestComponent(_props)
			return nil
		end
		expect(getElementName(createElement(TestComponent))).to.equal("TestComponent")
	end)

	it("returns the function source and line when it is anonymous", function()
		local name = getElementName(createElement(function(_props)
			return
		end))
		local scriptName = script:GetFullName()
		expect(name).to.equal(("<function %s:23>"):format(scriptName))
	end)

	it("returns the host component name", function()
		expect(getElementName(createElement("TextButton"))).to.equal("<TextButton>")
	end)
end
