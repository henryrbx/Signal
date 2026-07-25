# 📡 Signal

**Signal** is a modern communication framework for Roblox that unifies local events, networking, and synchronized state into a single, consistent API.

Whether you're firing a local signal, sending a `RemoteEvent`, invoking a `RemoteFunction`, or synchronizing replicated state, Signal provides the same clean developer experience on both the client and server.

Signal automatically creates and manages networking instances behind the scenes, eliminating manual setup and preventing common networking pitfalls such as race conditions.

---

## ✨ Features

- ⚡ Local Signals
- 📡 RemoteEvents
- 🛰️ UnreliableRemoteEvents
- 🔄 RemoteFunctions
- 🔄 State Synchronization
- 🤝 Guaranteed ACK Delivery
- 📦 Replay Buffers
- 🛡️ Event Deduplication
- 🚦 Request Rate Limiting
- ⚡ Promise-based Invocations
- 📊 Built-in Bandwidth Profiler
- 🐞 Debug Logging
- 🚀 Automatic Remote Creation
- 📦 Automatic Remote Caching
- 🖥️ Unified Client & Server API

---

# 📦 Installation

Place the package inside **ReplicatedStorage**.

```text
ReplicatedStorage
└── Packages
    └── Signal
```

Require it anywhere.

```lua
local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)
```

That's it.

Signal automatically creates and manages all networking instances. No folders, `RemoteEvents`, or `RemoteFunctions` need to be created manually.

---

# 🚀 Quick Start

## Local Signal

```lua
local Changed = Signal.new()

Changed:Connect(function(value)
    print("Changed:", value)
end)

Changed:Fire(10)
```

---

## Remote Event

```lua
local Damage = Signal.Event("Damage")

Damage:FireServer(20)
```

---

## Remote Function

```lua
local Inventory = Signal.Function("Inventory")

Inventory:InvokeServerAsync()
    :andThen(function(data)
        print(data.Coins)
    end)
```

---

## State Synchronization

```lua
-- Server
local Gold = Signal.State("PlayerGold", 100)

Gold:Set(250)

-- Client
Signal.State("PlayerGold"):Observe(function(value)
    print(value)
end)
```

---

## Unreliable Event

```lua
local Effects = Signal.Unreliable("Effects")

Effects:FireAll(Vector3.new(0, 10, 0))
```

---

Continue to the **Guide** for the complete API reference, advanced features, and practical examples.