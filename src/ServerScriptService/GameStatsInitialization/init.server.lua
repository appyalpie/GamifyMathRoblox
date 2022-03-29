--services and variables up top. allow access to globaldatastore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameStatsUtilities = require(script.GameStatsUtilities)

------Overall Game------
local PlayerStatsRF = ReplicatedStorage:WaitForChild("PlayerStatsRF")
local UpdateIsland3BarrierDownStatusRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("UpdateIsland3BarrierDownStatusRE")

------Math Blocks------

------24 Game------

local GameStatsStore = DataStoreService:GetDataStore("PlayerGameStats")

-- When a player joins get their data
Players.PlayerAdded:Connect(function(player)
    local success, returnedValue = pcall(function()
        return GameStatsStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or type(returnedValue) ~= "table" then
            GameStatsUtilities.initializePlayerGameStats(player)
        else
            GameStatsUtilities.setPlayerGameStats(player, returnedValue)
        end
    else -- Possible datastore throttle error
        GameStatsUtilities.initializePlayerGameStats(player)
    end
end)

-- when the player leaves, save their current checkpoint
Players.PlayerRemoving:Connect(function(player)
    local playerData = GameStatsUtilities.getPlayerData(player)
    local success, errorMessage = pcall(function()
        GameStatsStore:SetAsync(player.UserId, playerData)
    end)
    if not success then
        print(errorMessage)
    end
end)

PlayerStatsRF.OnServerInvoke = function(player, returnLevelStatsBool)
    return GameStatsUtilities.getPlayerData(player, returnLevelStatsBool)
end

UpdateIsland3BarrierDownStatusRE.OnServerEvent:Connect(function(player)
    GameStatsUtilities.updateIsland3BarrierDown(player)
end)