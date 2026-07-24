local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Types = require(script.Parent.Parent.Types)
local Shared = require(script.Parent.Parent.Shared)
local Registry = require(script.Parent.Registry)

local Unreliable = {}
Unreliable.__index = Unreliable

function Unreliable.New(name: string): any
	local instance = Registry.GetOrCreateRemote("UnreliableRemoteEvent", Shared.UNRELIABLE_FOLDER, name)
	local self = setmetatable({
		_name = name,
		_instance = instance :: UnreliableRemoteEvent,
		_isServer = RunService:IsServer(),
		_validators = nil :: { (any) -> boolean }?,
	}, Unreliable)
	return self
end

function Unreliable:SetSchema(...: (any) -> boolean): any
	self._validators = { ... }
	return self
end

function Unreliable:Connect(callback: (...any) -> ()): Types.Connection
	Shared.AssertType(callback, "function", "callback")
	Shared.Log("Connected listener to UnreliableRemoteEvent '" .. self._name .. "'")

	local wrappedCallback = callback
	if self._isServer and self._validators then
		wrappedCallback = function(player: Player, ...: any)
			local args = { ... }
			if not Shared.ValidateSchema(self._validators :: { (any) -> boolean }, args) then
				Shared.Warn(string.format("Dropped invalid packet from player %s on Unreliable '%s'", player.Name, self._name))
				return
			end
			callback(player, ...)
		end
	end

	local rbxConnection: RBXScriptConnection
	if self._isServer then
		rbxConnection = self._instance.OnServerEvent:Connect(wrappedCallback)
	else
		rbxConnection = self._instance.OnClientEvent:Connect(wrappedCallback)
	end

	return {
		Connected = true,
		Disconnect = function(conn)
			if conn.Connected then
				conn.Connected = false
				rbxConnection:Disconnect()
			end
		end,
	}
end

function Unreliable:FireServer(...: any): ()
	Shared.Assert(not self._isServer, "Cannot call FireServer() on the server.")
	Shared.Log("Fired UnreliableRemoteEvent '" .. self._name .. "' to Server")
	self._instance:FireServer(...)
end

function Unreliable:FireClient(player: Player, ...: any): ()
	Shared.Assert(self._isServer, "Cannot call FireClient() from the client.")
	Shared.Assert(typeof(player) == "Instance" and player:IsA("Player"), "FireClient requires a valid Player instance.")
	Shared.Log("Fired UnreliableRemoteEvent '" .. self._name .. "' to Client: " .. player.Name)
	self._instance:FireClient(player, ...)
end

function Unreliable:FireAll(...: any): ()
	Shared.Assert(self._isServer, "Cannot call FireAll() from the client.")
	Shared.Log("Fired UnreliableRemoteEvent '" .. self._name .. "' to All Clients")
	self._instance:FireAllClients(...)
end

function Unreliable:FireExcept(ignoredPlayer: Player, ...: any): ()
	Shared.Assert(self._isServer, "Cannot call FireExcept() from the client.")
	Shared.Assert(typeof(ignoredPlayer) == "Instance" and ignoredPlayer:IsA("Player"), "FireExcept requires a valid Player instance.")

	Shared.Log("Fired UnreliableRemoteEvent '" .. self._name .. "' to all except: " .. ignoredPlayer.Name)
	for _, player in Players:GetPlayers() do
		if player ~= ignoredPlayer then
			self._instance:FireClient(player, ...)
		end
	end
end

function Unreliable:Destroy(): ()
	Shared.Log("Destroyed UnreliableRemoteEvent '" .. self._name .. "'")
	if self._isServer then
		self._instance:Destroy()
	end
end

return Unreliable