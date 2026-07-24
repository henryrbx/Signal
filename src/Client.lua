local Event = require(script.Parent.Core.Event)
local Function = require(script.Parent.Core.Function)
local State = require(script.Parent.Core.State)

local Client = {}

function Client.Event(name: string)
	return Event.New(name, false)
end

function Client.Unreliable(name: string)
	return Event.New(name, true)
end

function Client.Function(name: string)
	return Function.New(name)
end

function Client.State(keyName: string, initialValue: any?)
	return State.New(keyName, initialValue)
end

return Client