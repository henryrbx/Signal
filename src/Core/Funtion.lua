local RunService = game:GetService("RunService")
local Shared = require(script.Parent.Parent.Shared)
local Registry = require(script.Parent.Registry)

local isServer = RunService:IsServer()

local Function = {}
Function.__index = Function

function Function.New(name: string)
	local self = setmetatable({}, Function)
	self._name = name
	self._remote = Registry.GetOrCreateRemote("RemoteFunction", Shared.FUNCTIONS_FOLDER, name) :: RemoteFunction
	self._rateLimit = 0
	self._playerFires = {} :: { [Player]: { count: number, lastReset: number } }
	return self
end

function Function:SetRateLimit(maxCallsPerSec: number)
	self._rateLimit = maxCallsPerSec
	return self
end

function Function:SetCallback(callback: (player: Player, ...any) -> ...any)
	Shared.Assert(isServer, "SetCallback can only be called on the Server")

	self._remote.OnServerInvoke = function(player: Player, ...)
		if self._rateLimit > 0 then
			local now = os.clock()
			local tracker = self._playerFires[player] or { count = 0, lastReset = now }

			if now - tracker.lastReset >= 1 then
				tracker.count = 0
				tracker.lastReset = now
			end

			tracker.count += 1
			self._playerFires[player] = tracker

			if tracker.count > self._rateLimit then
				warn(string.format("[Signal] Rate limit exceeded for %s on RemoteFunction '%s'", player.Name, self._name))
				return nil
			end
		end

		Registry.TrackPacket(self._name, 64)
		return callback(player, ...)
	end
end

-- Synchronous Yielding Invocation
function Function:InvokeServer(...): ...any
	Shared.Assert(not isServer, "InvokeServer can only be called on the Client")
	Registry.TrackPacket(self._name, 64)
	return self._remote:InvokeServer(...)
end

-- Feature: Promise-Based Async Invocation (Non-blocking)
function Function:InvokeServerAsync(...): { andThen: (self: any, onSuccess: (...any) -> ()) -> any, catch: (self: any, onFailure: (err: string) -> ()) -> any }
	Shared.Assert(not isServer, "InvokeServerAsync can only be called on the Client")

	local args = { ... }
	local promise = {}
	local successCb = nil
	local errorCb = nil

	function promise:andThen(cb)
		successCb = cb
		return promise
	end

	function promise:catch(cb)
		errorCb = cb
		return promise
	end

	task.spawn(function()
		Registry.TrackPacket(self._name, 64)
		local success, results = pcall(function()
			return { self._remote:InvokeServer(table.unpack(args)) }
		end)

		if success then
			if successCb then
				successCb(table.unpack(results))
			end
		else
			if errorCb then
				errorCb(tostring(results))
			else
				warn("[Signal Promise Error]: " .. tostring(results))
			end
		end
	end)

	return promise
end

return Function