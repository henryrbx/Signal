local Shared = {}

Shared.FOLDER_NAME = "SignalRemotes"
Shared.EVENTS_FOLDER = "Events"
Shared.FUNCTIONS_FOLDER = "Functions"
Shared.UNRELIABLE_FOLDER = "Unreliable"

Shared.TIMEOUT = 10

function Shared.Log(msg: string)
	-- Set to true to see full internal debug logs
	if false then
		print(string.format("[Signal Log] %s", msg))
	end
end

function Shared.Assert(condition: boolean, errorMessage: string)
	if not condition then
		error(string.format("[Signal Error] %s", errorMessage), 3)
	end
end

function Shared.AssertType(val: any, expectedType: string, paramName: string)
	if typeof(val) ~= expectedType then
		error(string.format("[Signal Error] Expected '%s' to be type %s, got %s", paramName, expectedType, typeof(val)), 3)
	end
end

return Shared