local Writer = {}

function Writer:write(value, ...)
	local indentation = self._indentation:rep(self._indentLevel)
	if select("#", ...) == 0 then
		table.insert(self._lines, indentation .. value)
	else
		table.insert(self._lines, indentation .. value:format(...))
	end
	return self
end

function Writer:pushLevel()
	self._indentLevel = self._indentLevel + 1
end

function Writer:popLevel()
	self._indentLevel = math.max(self._indentLevel - 1, 0)
end

function Writer:toString()
	return table.concat(self._lines, "\n")
end

local WriterMetatable = { __index = Writer }

return {
	new = function()
		return setmetatable({
            _lines={},
			_indentation = "    ",
			_indentLevel = 0,
		}, WriterMetatable)
	end,
}
