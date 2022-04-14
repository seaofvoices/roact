return function()
	local root = script.Parent.Parent
	local assign = require(root.assign)
	local createElement = require(root.createElement)
	local createFragment = require(root.createFragment)
	local Component = require(root.Component)
	local RobloxRenderer = require(root.RobloxRenderer)

	local createReconciler = require(root.createReconciler)

	local noopReconciler = nil

	if not _G.ENABLE_DEV_TOOLS then
		return
	end

	beforeEach(function()
		noopReconciler = createReconciler(RobloxRenderer)
	end)

	local TestComponent = Component:extend("TestComponent")

	function TestComponent:render()
		local children = {}
		for i = 1, self.props.renderElementCount do
			children[tostring(i)] = createElement("IntValue", { Value = i })
		end
		return createElement("Folder", {}, children)
	end

	local function MultiTestComponent(props)
		return createElement("Model", {}, {
			A = createElement(TestComponent, { renderElementCount = props.a }),
			B = createElement(TestComponent, { renderElementCount = props.b }),
		})
	end

	describe("tree updates", function()
		it("test something", function()
			local tree = noopReconciler.mountVirtualTree(createElement("StringValue", {
				Value = "first",
			}))

			noopReconciler.devTools.enableUpdateStats()

			noopReconciler.updateVirtualTree(
				tree,
				createElement("StringValue", {
					Value = "Second",
				})
			)

			local updates = noopReconciler.devTools.disableUpdateStats()

			expect(#updates).to.equal(1)

			local updateInfo = noopReconciler.devTools.formatUpdate(updates[1])
			expect(updateInfo).to.equal("<StringValue2>")
			expect(updateInfo:match("<StringValue2>")).to.be.ok()
		end)

		it("test something 2", function()
			local tree = noopReconciler.mountVirtualTree(createElement(TestComponent, {
				renderElementCount = 1,
			}))

			noopReconciler.devTools.enableUpdateStats()

			noopReconciler.updateVirtualTree(
				tree,
				createElement(TestComponent, {
					renderElementCount = 10,
				})
			)

			local updates = noopReconciler.devTools.disableUpdateStats()

			expect(#updates).to.equal(1)

			print("update=", updates[1])
			local updateInfo = noopReconciler.devTools.formatUpdate(updates[1])
			expect(updateInfo).to.equal("<TestComponent>")
			expect(updateInfo:match("<TestComponent>")).to.be.ok()
		end)

		itFOCUS("test something 3", function()
			local tree = noopReconciler.mountVirtualTree(createElement(MultiTestComponent, {
				a = 1,
				b = 2,
			}))

			noopReconciler.devTools.enableUpdateStats()

			noopReconciler.updateVirtualTree(
				tree,
				createElement(MultiTestComponent, {
					a = 2,
					b = 5,
				})
			)

			local updates = noopReconciler.devTools.disableUpdateStats()

			expect(#updates).to.equal(1)

			print("update=", updates[1])
			local updateInfo = noopReconciler.devTools.formatUpdate(updates[1])
            print(updateInfo)
			expect(updateInfo).to.be.ok("<TestComponent>")
			-- expect(updateInfo).to.equal("<TestComponent>")
			-- expect(updateInfo:match("<TestComponent>")).to.be.ok()
		end)
	end)
end
