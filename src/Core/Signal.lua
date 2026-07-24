local Types = require(script.Parent.Parent.Types)

type Node = {
	Callback: (...any) -> ()?,
	Next: Node?,
}

type SignalImpl = {
	__index: SignalImpl,
	_head: Node?,
	New: () -> Types.Signal<...any>,
	Connect: (self: any, callback: (...any) -> ()) -> Types.Connection,
	Once: (self: any, callback: (...any) -> ()) -> Types.Connection,
	Wait: (self: any) -> ...any,
	Fire: (self: any, ...any) -> (),
	DisconnectAll: (self: any) -> (),
	Destroy: (self: any) -> (),
}

local Signal = {} :: SignalImpl
Signal.__index = Signal

function Signal.New(): Types.Signal<...any>
	local self = setmetatable({
		_head = nil,
	}, Signal)
	return (self :: any) :: Types.Signal<...any>
end

function Signal:Connect(callback: (...any) -> ()): Types.Connection
	assert(type(callback) == "function", "[Signal Error] Connect callback must be a function.")

	local node: Node = {
		Callback = callback,
		Next = self._head,
	}
	self._head = node

	local connection = {
		Connected = true,
	}

	function connection:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false

		if Signal._head == node then
			Signal._head = node.Next
		else
			local prev = Signal._head
			while prev and prev.Next ~= node do
				prev = prev.Next
			end
			if prev then
				prev.Next = node.Next
			end
		end
		node.Callback = nil
		node.Next = nil
	end

	return connection
end

function Signal:Once(callback: (...any) -> ()): Types.Connection
	local connection: Types.Connection? = nil
	connection = self:Connect(function(...)
		if connection then
			connection:Disconnect()
		end
		callback(...)
	end)
	return connection :: Types.Connection
end

function Signal:Wait(): ...any
	local thread = coroutine.running()
	local connection: Types.Connection? = nil

	connection = self:Connect(function(...)
		if connection then
			connection:Disconnect()
		end
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

function Signal:Fire(...: any): ()
	local node = self._head
	while node do
		local callback = node.Callback
		if callback then
			task.spawn(callback, ...)
		end
		node = node.Next
	end
end

function Signal:DisconnectAll(): ()
	local node = self._head
	while node do
		local nextNode = node.Next
		node.Callback = nil
		node.Next = nil
		node = nextNode
	end
	self._head = nil
end

function Signal:Destroy(): ()
	self:DisconnectAll()
end

return Signal