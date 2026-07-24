local Types = require(script.Parent.Types)
local Shared = require(script.Parent.Shared)

local SignalClass = require(script.Parent.Core.Signal)
local RemoteClass = require(script.Parent.Core.Remote)
local FunctionClass = require(script.Parent.Core.Function)
local UnreliableClass = require(script.Parent.Core.Unreliable)

local Server = {}

function Server.SetDebug(enabled: boolean): ()
	Shared.AssertType(enabled, "boolean", "enabled")
	Shared.DebugEnabled = enabled
	Shared.Log("Debug mode " .. (enabled and "enabled" or "disabled"))
end

function Server.new<T...>(): Types.Signal<T...>
	return SignalClass.New()
end

function Server.Event<T...>(name: string): Types.ServerRemoteEvent<T...>
	Shared.AssertType(name, "string", "name")
	local remote = RemoteClass.New(name)
	return {
		SetSchema = function(_, ...) remote:SetSchema(...) return remote end,
		Connect = function(_, callback) return remote:Connect(callback) end,
		FireClient = function(_, player, ...) remote:FireClient(player, ...) end,
		FireAll = function(_, ...) remote:FireAll(...) end,
		FireExcept = function(_, ignoredPlayer, ...) remote:FireExcept(ignoredPlayer, ...) end,
		Destroy = function(_) remote:Destroy() end,
	}
end

function Server.Function<T..., R...>(name: string): Types.ServerRemoteFunction<T..., R...>
	Shared.AssertType(name, "string", "name")
	local fn = FunctionClass.New(name)
	return {
		SetCallback = function(_, callback) fn:SetCallback(callback) end,
		Destroy = function(_) fn:Destroy() end,
	}
end

function Server.Unreliable<T...>(name: string): Types.ServerRemoteEvent<T...>
	Shared.AssertType(name, "string", "name")
	local unreliable = UnreliableClass.New(name)
	return {
		SetSchema = function(_, ...) unreliable:SetSchema(...) return unreliable end,
		Connect = function(_, callback) return unreliable:Connect(callback) end,
		FireClient = function(_, player, ...) unreliable:FireClient(player, ...) end,
		FireAll = function(_, ...) unreliable:FireAll(...) end,
		FireExcept = function(_, ignoredPlayer, ...) unreliable:FireExcept(ignoredPlayer, ...) end,
		Destroy = function(_) unreliable:Destroy() end,
	}
end

return Server