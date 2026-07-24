local RunService = game:GetService("RunService")
local Shared = require(script.Parent.Parent.Shared)
local Event = require(script.Parent.Event)

local isServer = RunService:IsServer()

local State = {}
State.__index = State

function State.New(keyName: string, initialValue: any?)
	Shared.AssertType(keyName, "string", "keyName")

	local self = setmetatable({}, State)
	self._key = keyName
	self._value = initialValue
	self._event = Event.New("_StateSync_" .. keyName, false)

	if not isServer then
		self._event:Connect(function(newValue)
			self._value = newValue
			if self._observer then
				self._observer(newValue)
			end
		end)
	end

	return self
end

function State:Set(newValue: any)
	Shared.Assert(isServer, "State:Set can only be called on the Server")
	self._value = newValue
	self._event:FireAll(newValue)
end

function State:Get(): any
	return self._value
end

function State:Observe(callback: (value: any) -> ())
	self._observer = callback
	if self._value ~= nil then
		callback(self._value)
	end
end

return State