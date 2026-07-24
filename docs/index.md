# 📡 Signal

**Signal** is a modern networking framework for Roblox that provides a unified API for:

- ⚡ Local Signals
- 📡 RemoteEvents
- 🛰️ UnreliableRemoteEvents
- 🔄 RemoteFunctions

Signal automatically creates and manages networking instances, so you never need to manually create `RemoteEvents` or `RemoteFunctions`.

## Features

- 🚀 Automatic remote creation
- 📦 Automatic caching
- ⚡ Local Signals
- 📡 Reliable RemoteEvents
- 🛰️ UnreliableRemoteEvents
- 🔄 RemoteFunctions
- 🧹 Memory-safe connections
- 🐞 Optional debug logging
- 🖥️ Same API on both Client and Server

---

## Installation

Place the package inside **ReplicatedStorage**.

```text
ReplicatedStorage
└── Packages
    └── Signal
```

Require it anywhere.

```lua
local Signal = require(ReplicatedStorage.Packages.Signal)
```

No setup is required.

---

## Quick Start

### Local Signal

```lua
local Changed = Signal.Signal()

Changed:Connect(function(value)
    print(value)
end)

Changed:Fire(10)
```

### RemoteEvent

```lua
local Damage = Signal.Event("Damage")
```

### RemoteFunction

```lua
local Inventory = Signal.Function("Inventory")
```

### UnreliableRemoteEvent

```lua
local Effects = Signal.Unreliable("Effects")
```

Continue to the **Guide** for the full API and examples.