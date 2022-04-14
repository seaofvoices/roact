local suffixes = { "ms", "us", "ns" }
local LAST_SUFFIX = #suffixes

local function formatDuration(duration)
	if duration < 0 then
		return "-" .. formatDuration(math.abs(duration))
	end
	if duration == 0 then
		return "0s"
	end

	if duration < 1 then
		local position = -math.floor(math.log10(duration))
		local factor = 1 + math.floor((position - 1) / 3)
		factor = math.min(factor, LAST_SUFFIX)

		local scaledDuration = duration * math.pow(1000, factor)

		local precision = "%0.0f"
		if scaledDuration < 10 then
			precision = "%0.3f"
		elseif scaledDuration < 100 then
			precision = "%0.2f"
		elseif scaledDuration < 1000 then
			precision = "%0.1f"
		end

		local value = precision:format(scaledDuration)
		local stripZeros = value:match("^(%d+%.[1-9]*)0*$")
		if stripZeros then
			value = stripZeros
		end
		if value:sub(-1, -1) == "." then
			value = value:sub(1, -2)
		end

		return value .. suffixes[factor]
	else
		local precision = "%0.0f"
		if duration < 10 then
			precision = "%0.3f"
		elseif duration < 100 then
			precision = "%0.2f"
		elseif duration < 1000 then
			precision = "%0.1f"
		end

		local value = precision:format(duration)
		local stripZeros = value:match("^(%d+%.[1-9]*)0*$")
		if stripZeros then
			value = stripZeros
		end
		if value:sub(-1, -1) == "." then
			value = value:sub(1, -2)
		end

		return value .. "s"
	end
end

return formatDuration
