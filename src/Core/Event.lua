local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Shared = require(script.Parent.Parent.Shared)
local Registry = require(script.Parent.Registry)

local isServer = RunService:IsServer()

local Event = {}
Event.__index = Event

export type EventConfig = {
	ReplayBufferCapacity: number?,
	DeduplicationCooldown: number?,
}

function Event.New(name: string, isUnreliable: boolean?)
	Shared.AssertType(name, "string", "name")

	local className = if isUnreliable then "UnreliableRemoteEvent" else "RemoteEvent"
	local folder = if isUnreliable then Shared.UNRELIABLE_FOLDER else Shared.EVENTS_FOLDER

	local self = setmetatable({}, Event)
	self._name = name
	-- Correct order: className ("RemoteEvent"), subfolderName ("Events"), remoteName ("RoundState")
	self._remote = Registry.GetOrCreateRemote(className, folder, name) :: RemoteEvent
	self._config = {
		ReplayBufferCapacity = 0,
		DeduplicationCooldown = 0,
	} :: EventConfig

	self._buffer = {} :: { { any } }
	self._lastFired = {} :: { [Player | string]: number }

	return self
end

function Event:SetReplayBuffer(capacity: number)
	self._config.ReplayBufferCapacity = capacity
	return self
end

function Event:SetDeduplication(cooldown: number)
	self._config.DeduplicationCooldown = cooldown
	return self
end

-- Fire from Client to Server
function Event:FireServer(...)
	local now = os.clock()
	if self._config.DeduplicationCooldown and self._config.DeduplicationCooldown > 0 then
		if self._lastFired["Client"] and (now - self._lastFired["Client"]) < self._config.DeduplicationCooldown then
			return -- Dropped due to deduplication
		end
		self._lastFired["Client"] = now
	end

	Registry.TrackPacket(self._name, 32)
	self._remote:FireServer(...)
end

-- Fire from Server to Client
function Event:FireClient(player: Player, ...)
	Shared.Assert(isServer, "FireClient can only be called from the Server")

	local now = os.clock()
	if self._config.DeduplicationCooldown and self._config.DeduplicationCooldown > 0 then
		if self._lastFired[player] and (now - self._lastFired[player]) < self._config.DeduplicationCooldown then
			return
		end
		self._lastFired[player] = now
	end

	-- Save to Replay Buffer if active
	if self._config.ReplayBufferCapacity and self._config.ReplayBufferCapacity > 0 then
		table.insert(self._buffer, { ... })
		if #self._buffer > self._config.ReplayBufferCapacity then
			table.remove(self._buffer, 1)
		end
	end

	Registry.TrackPacket(self._name, 32)
	self._remote:FireClient(player, ...)
end

function Event:FireAll(...)
	Shared.Assert(isServer, "FireAll can only be called from the Server")

	if self._config.ReplayBufferCapacity and self._config.ReplayBufferCapacity > 0 then
		table.insert(self._buffer, { ... })
		if #self._buffer > self._config.ReplayBufferCapacity then
			table.remove(self._buffer, 1)
		end
	end

	Registry.TrackPacket(self._name, 32)
	self._remote:FireAllClients(...)
end

-- Two-Way Event Acknowledgment (Server side)
function Event:FireClientWithAck(player: Player, timeout: number?, ...): (boolean)
	Shared.Assert(isServer, "FireClientWithAck can only be called from the Server")
	local ackId = HttpService:GenerateGUID(false)
	local acknowledged = false
	local waitTime = timeout or 5

	local connection
	connection = self._remote.OnServerEvent:Connect(function(sender, responseAckId)
		if sender == player and responseAckId == ackId then
			acknowledged = true
			connection:Disconnect()
		end
	end)

	self._remote:FireClient(player, ackId, ...)

	local start = os.clock()
	while not acknowledged and (os.clock() - start) < waitTime do
		task.wait(0.05)
	end

	if connection.Connected then connection:Disconnect() end
	return acknowledged
end

function Event:Connect(callback: (...any) -> ())
	if isServer then
		return self._remote.OnServerEvent:Connect(function(player, ...)
			callback(player, ...)
		end)
	else
		-- On Client: Check for two-way ACK payloads first
		local connection = self._remote.OnClientEvent:Connect(function(...)
			local args = { ... }
			-- Check if first argument is an AckId GUID
			if typeof(args[1]) == "string" and string.len(args[1]) == 36 then
				local ackId = args[1]
				self._remote:FireServer(ackId)
				table.remove(args, 1)
				callback(table.unpack(args))
			else
				callback(...)
			end
		end)

		-- Replay Buffer Auto-Flush on connection
		if self._config.ReplayBufferCapacity and #self._buffer > 0 then
			for _, cachedArgs in ipairs(self._buffer) do
				task.spawn(callback, table.unpack(cachedArgs))
			end
		end

		return connection
	end
end

return Event