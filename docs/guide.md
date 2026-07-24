# Guide

## Local Signals

Local signals never cross the network.

```lua
local Changed = Signal.Signal()

Changed:Connect(function(value)
    print(value)
end)

Changed:Fire(100)
```

### Methods

```lua
Signal:Connect(callback)
Signal:Once(callback)
Signal:Wait()
Signal:Fire(...)
Signal:Destroy()
```

---

# Remote Events

Reliable communication between the server and client.

Create or get an event.

```lua
local Damage = Signal.Event("Damage")
```

## Server

```lua
Damage:Connect(function(player, amount)

end)

Damage:FireClient(player, 20)

Damage:FireAll(20)

Damage:FireExcept(player, 20)
```

## Client

```lua
Damage:Connect(function(amount)

end)

Damage:FireServer(20)
```

---

# Remote Functions

Used when the client needs a response from the server.

```lua
local Inventory = Signal.Function("Inventory")
```

## Server

```lua
Inventory:SetCallback(function(player)

    return {
        Coins = 100,
        Gems = 10
    }

end)
```

## Client

```lua
local Data = Inventory:InvokeServer()

print(Data.Coins)
```

---

# Unreliable Events

Uses Roblox's `UnreliableRemoteEvent`.

Perfect for:

- Particle effects
- Camera shake
- Bullet tracers
- Sound effects
- Position updates

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

# Debug Mode

Enable logging while developing.

```lua
Signal.SetDebug(true)
```

Disable it when shipping.

```lua
Signal.SetDebug(false)
```

Example output:

```text
[Signal] Created Event "Damage"
[Signal] Connected "Damage"
[Signal] Fired "Damage"
[Signal] Destroyed "Damage"
```

---

# Automatic Registry

Signal automatically manages networking instances.

When you call:

```lua
Signal.Event("Damage")
```

the framework will:

- Create the RemoteEvent on the server if it doesn't exist.
- Wait for it on the client.
- Cache it for future use.
- Prevent duplicate creation.

No manual setup in `ReplicatedStorage` is required.

---

# API Summary

| Constructor | Description |
|-------------|-------------|
| `Signal.Signal()` | Creates a local signal |
| `Signal.Event(name)` | Gets or creates a `RemoteEvent` |
| `Signal.Function(name)` | Gets or creates a `RemoteFunction` |
| `Signal.Unreliable(name)` | Gets or creates an `UnreliableRemoteEvent` |

## Local Signal

- `Connect()`
- `Once()`
- `Wait()`
- `Fire()`
- `Destroy()`

## Remote Event

Client

- `FireServer()`
- `Connect()`

Server

- `FireClient()`
- `FireAll()`
- `FireExcept()`
- `Connect()`

## Remote Function

Client

- `InvokeServer()`

Server

- `SetCallback()`

## Utilities

```lua
Signal.SetDebug(enabled)
```