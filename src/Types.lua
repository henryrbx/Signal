export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Signal<T... = ...any> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

export type Validator = (value: any) -> boolean

-- Server Remote Event Wrapper
export type ServerRemoteEvent<T... = ...any> = {
	SetSchema: (self: ServerRemoteEvent<T...>, ...Validator) -> ServerRemoteEvent<T...>,
	Connect: (self: ServerRemoteEvent<T...>, callback: (player: Player, T...) -> ()) -> Connection,
	FireClient: (self: ServerRemoteEvent<T...>, player: Player, T...) -> (),
	FireAll: (self: ServerRemoteEvent<T...>, T...) -> (),
	FireExcept: (self: ServerRemoteEvent<T...>, ignoredPlayer: Player, T...) -> (),
	Destroy: (self: ServerRemoteEvent<T...>) -> (),
}

-- Client Remote Event Wrapper
export type ClientRemoteEvent<T... = ...any> = {
	Connect: (self: ClientRemoteEvent<T...>, callback: (T...) -> ()) -> Connection,
	FireServer: (self: ClientRemoteEvent<T...>, T...) -> (),
	Destroy: (self: ClientRemoteEvent<T...>) -> (),
}

-- Remote Function Wrappers
export type ServerRemoteFunction<T... = ...any, R... = ...any> = {
	SetCallback: (self: ServerRemoteFunction<T..., R...>, callback: (player: Player, T...) -> R...) -> (),
	Destroy: (self: ServerRemoteFunction<T..., R...>) -> (),
}

export type ClientRemoteFunction<T... = ...any, R... = ...any> = {
	InvokeServer: (self: ClientRemoteFunction<T..., R...>, T...) -> R...,
	InvokeServerWithTimeout: (self: ClientRemoteFunction<T..., R...>, timeoutSeconds: number, T...) -> (boolean, R...),
	Destroy: (self: ClientRemoteFunction<T..., R...>) -> (),
}

-- Package Root API Interface
export type PackageAPI = {
	SetDebug: (enabled: boolean) -> (),
	new: <T...>() -> Signal<T...>,
	Event: <T...>(name: string) -> any,
	Function: <T..., R...>(name: string) -> any,
	Unreliable: <T...>(name: string) -> any,
}

return nil