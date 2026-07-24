**Signal** is a high-performance, feature-packed networking package for Roblox designed to make client-server communication fast, safe, and effortless.

It handles automatic remote instantiation, race-condition prevention, state synchronization, promise-based invocations, rate-limiting, and bandwidth diagnostics out of the box.

---
## 🛠️ Installation

* Get the `Signal` Package from `Creator Store`.
* Copy the whole `Src/` from github.
* Read the Docs [Here](https://henryrbx.github.io/Signal/)

## ⚡ Features

* 🚀 **Zero-Setup Remotes:** Automatic creation and pooling of `RemoteEvent` and `RemoteFunction` instances.
* 🛡️ **Race-Condition Proof:** Prevents client timeout crashes on slow-loading games.
* 📦 **Event Replay Buffers:** Caches recent state updates for late-joining players.
* 🛑 **Built-in Deduplication:** Ignores rapid spam calls made within a configured time window.
* ⚡ **Non-Blocking Promises:** Call `InvokeServerAsync()` without freezing client threads.
* 🤝 **Two-Way ACK Delivery:** Confirms packet receipt for critical gameplay events.
* 🔄 **Property State Synchronization:** Bind server variables directly to client UI observers.
* 📊 **Bandwidth Profiler:** Real-time bandwidth usage reports and diagnostic statistics.
