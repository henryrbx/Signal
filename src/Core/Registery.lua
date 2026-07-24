local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = require(script.Parent.Parent.Shared)

local Registry = {}

local cache: { [string]: Instance } = {}
local isServer = RunService:IsServer()

local rootFolder: Folder? = nil
local folders: { [string]: Folder } = {}

-- Bandwidth Profiler Storage
local profilerEnabled = false
local profilerStats = {}

local function getRootFolder(): Folder
	if rootFolder then return rootFolder end

	if isServer then
		rootFolder = ReplicatedStorage:FindFirstChild(Shared.FOLDER_NAME) :: Folder
		if not rootFolder then
			local newFolder = Instance.new("Folder")
			newFolder.Name = Shared.FOLDER_NAME
			newFolder.Parent = ReplicatedStorage
			rootFolder = newFolder
		end
	else
		rootFolder = ReplicatedStorage:WaitForChild(Shared.FOLDER_NAME) :: Folder
	end

	return rootFolder :: Folder
end

local function getSubFolder(folderName: string): Folder
	if folders[folderName] then return folders[folderName] end

	local parent = getRootFolder()
	if isServer then
		local folder = parent:FindFirstChild(folderName) :: Folder
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = parent
		end
		folders[folderName] = folder
	else
		local folder = parent:WaitForChild(folderName) :: Folder
		folders[folderName] = folder
	end

	return folders[folderName]
end

if isServer then
	task.spawn(function()
		getSubFolder(Shared.EVENTS_FOLDER)
		getSubFolder(Shared.FUNCTIONS_FOLDER)
		getSubFolder(Shared.UNRELIABLE_FOLDER)
	end)
end

function Registry.GetOrCreateRemote<T>(className: string, subfolderName: string, remoteName: string): T
	Shared.AssertType(remoteName, "string", "remoteName")

	local cacheKey = subfolderName .. "/" .. remoteName
	if cache[cacheKey] then
		return cache[cacheKey] :: any
	end

	local targetFolder = getSubFolder(subfolderName)

	if isServer then
		local instance = targetFolder:FindFirstChild(remoteName)
		if not instance then
			instance = Instance.new(className)
			instance.Name = remoteName
			instance.Parent = targetFolder
		end
		cache[cacheKey] = instance
		return instance :: any
	else
		local instance = targetFolder:WaitForChild(remoteName)
		cache[cacheKey] = instance
		return instance :: any
	end
end

-- Profiler API
function Registry.EnableProfiler(enable: boolean)
	profilerEnabled = enable
	if enable then
		print("[Signal Profiler] Bandwidth Profiler Enabled!")
	end
end

function Registry.TrackPacket(remoteName: string, bytes: number)
	if not profilerEnabled then return end
	if not profilerStats[remoteName] then
		profilerStats[remoteName] = { calls = 0, bytes = 0 }
	end
	profilerStats[remoteName].calls += 1
	profilerStats[remoteName].bytes += bytes
end

-- Print stats periodically if enabled
task.spawn(function()
	while true do
		task.wait(10)
		if profilerEnabled then
			print("--- [Signal Bandwidth Profiler Report] ---")
			for remote, data in pairs(profilerStats) do
				print(string.format("Remote: %s | Calls (10s): %d | Total Data: %.2f KB", remote, data.calls, data.bytes / 1024))
			end
			table.clear(profilerStats)
		end
	end
end)

return Registry