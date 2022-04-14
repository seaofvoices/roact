local ElementKind = require(script.Parent.Parent.ElementKind)

local function getElementName(element)
	local kind = ElementKind.of(element)
	if kind == ElementKind.Host then
		return ("<%s>"):format(element.component)
	elseif kind == ElementKind.Function then
		local functionName = debug.info(element.component, "n")

		if functionName ~= "" then
			return functionName
		end

		local source, line = debug.info(element.component, "sl")

		return ("<function %s:%d>"):format(source, line)
	elseif kind == ElementKind.Stateful then
		return element.component.__componentName
	elseif kind == ElementKind.Portal then
		return "<Portal>"
	elseif kind == ElementKind.Fragment then
		return "<Fragment>"
	else
		return "<invalid element>"
	end
end

return getElementName
