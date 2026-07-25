# Guide

This guide covers every feature available in Signal, from local signals to advanced networking features.

---

# Local Signals

Local signals never cross the network and execute only in the environment they were created.

```lua
local Changed = Signal.new()

Changed:Connect(function(value)
    print(value)
end)

Changed:Fire(100)
```

## Methods

| Method | Description |
|---------|-------------|
| `Connect(callback)` | Connects a listener. |
| `Once(callback)` | Runs once then disconnects. |
| `Wait()` | Yields until fired. |
| `Fire(...)` | Fires the signal. |
| `Destroy()` | Cleans up the signal. |

---

# Remote Events

Reliable communication between the server and clients.

Create or retrieve an event.

```lua
local Damage = Signal.Event("Damage")
```

## Server

```lua
Damage:Connect(function(player, amount)
    print(player.Name, "took", amount, "damage")
end)

Damage:FireClient(player, 20)

Damage:FireAll(20)

Damage:FireExcept(player, 20)
```

## Client

```lua
Damage:Connect(function(amount)
    print("Received damage:", amount)
end)

Damage:FireServer(20)
```

---

## Replay Buffers

Replay Buffers remember previous payloads so late-loading clients immediately receive the latest state.

```lua
local GameState = Signal.Event("GameState")
    :SetReplayBuffer(1)

GameState:FireAll("Intermission", 30)
```

---

## Deduplication

Ignore duplicate fires within a configurable cooldown.

```lua
local Attack = Signal.Event("Attack")
    :SetDeduplication(0.5)
```

---

# Remote Functions

Remote Functions allow clients to request data from the server.

```lua
local Inventory = Signal.Function("Inventory")
```

## Server

```lua
Inventory:SetRateLimit(5)

Inventory:SetCallback(function(player)
    return {
        Coins = 100,
        Gems = 10,
    }
end)
```

## Client

### Synchronous

```lua
local Data = Inventory:InvokeServer()

print(Data.Coins)
```

### Asynchronous

```lua
Inventory:InvokeServerAsync()
    :andThen(function(data)
        print(data.Coins)
    end)
    :catch(function(err)
        warn(err)
    end)
```

---

# Guaranteed ACK Delivery

Guarantees that important packets reach the client before continuing.

Perfect for:

- Rewards
- Purchases
- Cutscenes
- Trading
- Match Results

```lua
local Reward = Signal.Event("GiveReward")

task.spawn(function()

    local Success = Reward:FireClientWithAck(
        player,
        "LegendarySword"
    )

    if Success then
        print("Client confirmed receipt!")
    end

end)
```

Client

```lua
Reward:Connect(function(item)

    print(item)

end)
```

Signal automatically handles acknowledgment packets.

---

# State Synchronization

Synchronize server-side values with client observers.

## Server

```lua
local Gold = Signal.State("PlayerGold", 100)

Gold:Set(250)
```

## Client

```lua
Signal.State("PlayerGold"):Observe(function(value)

    print(value)

end)
```

## Methods

### Server

- `Set(value)`
- `Get()`

### Client

- `Observe(callback)`
- `Get()`

---

# Unreliable Events

Uses Roblox's `UnreliableRemoteEvent` for high-frequency, non-critical communication.

Ideal for:

- Particles
- Camera Shake
- Bullet Tracers
- Footsteps
- Character Movement
- Vehicle Physics

```lua
local Effects = Signal.Unreliable("Effects")
```

Server

```lua
Effects:FireAll(position)
```

Client

```lua
Effects:FireServer(position)
```

---

# Debugging & Profiling

## Debug Logging

Enable lifecycle logs while developing.

```lua
Signal.SetDebug(true)
```

Example:

```text
[Signal] Created Event "Damage"
[Signal] Connected "Damage"
[Signal] Fired "Damage"
[Signal] Destroyed "Damage"
```

Disable logging.

```lua
Signal.SetDebug(false)
```

---

## Bandwidth Profiler

Monitor packet counts and payload sizes.

```lua
Signal.EnableProfiler(true)
```

Example report:

```text
--- [Signal Bandwidth Report] ---

Remote: FetchInventory
Calls: 4
Data: 0.24 KB

Remote: PlayerGold
Calls: 2
Data: 0.06 KB
```

---

# Automatic Registry

Signal automatically manages networking instances.

When you call

```lua
Signal.Event("Damage")
```

Signal will automatically:

- Create the remote on the server if it doesn't exist.
- Wait safely for replication on the client.
- Cache the remote for future lookups.
- Prevent duplicate creation.
- Organize networking instances internally.

No manual setup inside `ReplicatedStorage` is required.

---

# API Summary

## Constructors

| Constructor | Description |
|-------------|-------------|
| `Signal.new` | Creates a local signal. |
| `Signal.Event(name)` | Gets or creates a `RemoteEvent`. |
| `Signal.Function(name)` | Gets or creates a `RemoteFunction`. |
| `Signal.Unreliable(name)` | Gets or creates an `UnreliableRemoteEvent`. |
| `Signal.State(name, default)` | Creates or retrieves a synchronized state. |

---

## Local Signal

- `Connect()`
- `Once()`
- `Wait()`
- `Fire()`
- `Destroy()`

---

## Remote Event

### Client

- `FireServer()`
- `Connect()`

### Server

- `FireClient()`
- `FireAll()`
- `FireExcept()`
- `FireClientWithAck()`
- `SetReplayBuffer()`
- `SetDeduplication()`
- `Connect()`

---

## Remote Function

### Client

- `InvokeServer()`
- `InvokeServerAsync()`

### Server

- `SetCallback()`
- `SetRateLimit()`

---

## State

### Client

- `Observe()`
- `Get()`

### Server

- `Set()`
- `Get()`

---

## Utilities

```lua
Signal.SetDebug(enabled)

Signal.EnableProfiler(enabled)
```