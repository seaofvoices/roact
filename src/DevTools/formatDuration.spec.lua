return function()
	local formatDuration = require(script.Parent.formatDuration)

	local cases = {
		[0] = "0s",
        [1] = "1s",
        [100] = "100s",
        [100.2] = "100.2s",
        [1000.2] = "1000s",
        [1.5] = "1.5s",
        [1.52] = "1.52s",
        [1.527] = "1.527s",
        [1.5271] = "1.527s",
        [10.5271] = "10.53s",
        [0.1] = "100ms",
        [0.2] = "200ms",
        [0.01] = "10ms",
        [0.001] = "1ms",
        [0.0001] = "100us",
        [0.00001] = "10us",
        [0.000001] = "1us",
        [0.0000001] = "100ns",
        [0.00000001] = "10ns",
        [0.000000001] = "1ns",
        [0.0000000001] = "0.1ns",
        [0.5] = "500ms",
        [0.05] = "50ms",
        [0.005] = "5ms",
        [0.0051] = "5.1ms",
        [0.0009999] = "999.9us",
        [0.00099999] = "1000us",
	}

	for value, expected in pairs(cases) do
		it(("formats `%s` as `%s`"):format(tostring(value), expected), function()
			expect(formatDuration(value)).to.equal(expected)
		end)
	end
end
