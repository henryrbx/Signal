--[[
	Signal Framework
	Main Entry Point for Client & Server
]]

local RunService = game:GetService("RunService")
local Event = require(script.Core.Event)
local Function = require(script.Core.Function)
local State = require(script.Core.State)
local Registry = require(script.Core.Registry)

local Signal = {}

function Signal.Event(name: string)
	return Event.New(name, false)
end

function Signal.Unreliable(name: string)
	return Event.New(name, true)
end

function Signal.Function(name: string)
	return Function.New(name)
end

function Signal.State(keyName: string, initialValue: any?)
	return State.New(keyName, initialValue)
end

function Signal.EnableProfiler(enable: boolean)
	Registry.EnableProfiler(enable)
end

return Signal