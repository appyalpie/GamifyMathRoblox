--services and variables up top. allow access to globaldatastore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameStatsUtilities = require(script.GameStatsUtilities)

------Overall Game------
--local IncrementCurrencyRE = ReplicatedStorage.RemoteEvents:WaitForChild("IncrementCurrencyRE")
--local IncrementXPRE = ReplicatedStorage.RemoteEvents:WaitForChild("IncrementXPRE")
local PlayerStatsRF = ReplicatedStorage:WaitForChild("PlayerStatsRF")

------Math Blocks------

------24 Game------
local IncrementWinsRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("IncrementWinsRE")
local NPCDefeatedRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("NPCDefeatedRE")
local SaveSolutionRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("SaveSolutionRE")

local GameStatsStore = DataStoreService:GetDataStore("PlayerGameStats")

-- When a player joins get their data
Players.PlayerAdded:Connect(function(player)
    GameStatsUtilities.initializePlayerGameStats(player)
end)

-- when the player leaves, save their current checkpoint
Players.PlayerRemoving:Connect(function(player)
    GameStatsUtilities.savePlayerGameStats(player)
end)

PlayerStatsRF.OnServerInvoke = function(player)
    return GameStatsUtilities.getPlayerData(player)
end