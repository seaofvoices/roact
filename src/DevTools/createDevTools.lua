local getElementName = require(script.Parent.getElementName)
local Writer = require(script.Parent.Writer)
local formatDuration = require(script.Parent.formatDuration)

local UPDATE_KIND_TO_LABEL = {
	update = "updated in",
	mount = "mounted in",
	unmount = "unmounted in",
	replace = "replaced in",
}
local DEFAULT_UPDATE_LABEL = "did work for"

local function createDevTools()
	local devTools = {
		getElementName = getElementName,
		_collectUpdateStats = nil,
		_virtualNodeUpdates = {},
		_currentVirtualNodeUpdate = nil,
	}

	function devTools.enableUpdateStats()
		if devTools._collectUpdateStats == nil then
			devTools._collectUpdateStats = 1
		else
			devTools._collectUpdateStats = devTools._collectUpdateStats + 1
		end
	end

	function devTools.disableUpdateStats()
		if devTools._collectUpdateStats == 1 then
			devTools._collectUpdateStats = nil
			local updates = devTools._virtualNodeUpdates
			devTools._virtualNodeUpdates = {}
			return updates
		else
			devTools._collectUpdateStats = devTools._collectUpdateStats - 1
			return {}
		end
	end

	local function sortByDuration(a, b)
		return a.duration >= b.duration
	end

	local function formatPercentage(alpha)
		return tostring(math.round(alpha * 100))
	end

	function devTools.formatUpdate(update)
		local writer = Writer.new()

		local totalChildren = #update.children

		writer:write("%s updated in %s", update.name, formatDuration(update.duration))

		if totalChildren > 0 then
			local current = update
			local index = 1
			local stack = {}

			table.sort(current.children, sortByDuration)
			writer:pushLevel()

			while current ~= nil do
				local child = current.children[index]

				if child == nil then
					local info = table.remove(stack)

					if info == nil then
						current = nil
					else
						current = info.parent
						index = info.index
						writer:popLevel()
					end
				else
					local updateType = UPDATE_KIND_TO_LABEL[child.kind] or DEFAULT_UPDATE_LABEL

					writer:write(
						"- %s %s %s [%s%%]",
						child.name,
						updateType,
						formatDuration(child.duration),
						formatPercentage(child.duration / current.duration)
					)

					if #child.children > 0 then
						table.insert(stack, { parent = current, index = index + 1 })
						table.sort(child.children, sortByDuration)
						writer:pushLevel()
						current = child
						index = 1
					else
						index = index + 1
					end
				end
			end

			writer:popLevel()
		end

		return writer:toString()
	end

	function devTools._reportStartVirtualNodeUpdate(name, kind)
		if not devTools._collectUpdateStats then
			return
		end

		local current = devTools._currentVirtualNodeUpdate
		local update = {
			name = name,
			kind = kind,
			duration = nil,
			start = nil,
			parent = current,
			children = {},
		}
		if current ~= nil then
			table.insert(current.children, update)
		end
		devTools._currentVirtualNodeUpdate = update
		update.start = os.clock()
	end

	function devTools._reportEndVirtualNodeUpdate()
		if not devTools._collectUpdateStats then
			return
		end

		local current = devTools._currentVirtualNodeUpdate
		if current == nil then
			error("cannot match end of update with a virtual node")
		end

		current.duration = os.clock() - current.start
		current.start = nil

		if current.parent ~= nil then
			devTools._currentVirtualNodeUpdate = current.parent
		else
			table.insert(devTools._virtualNodeUpdates, current)
			devTools._currentVirtualNodeUpdate = nil
		end
	end

	return devTools
end

return createDevTools
