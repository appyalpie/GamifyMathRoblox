local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelSystem = require(ServerScriptService.Utilities.LevelSystem)
local QuestTrackerUtilities = require(ServerScriptService.GameStatsInitialization.QuestTracker.QuestTrackerUtilities)
local GameStatsUtilities = require(ServerScriptService.GameStatsInitialization.GameStatsUtilities)
local CheckpointUtilities = require(ServerScriptService:WaitForChild("CheckpointsInitialization"):WaitForChild("CheckpointUtilities"))

local PlayerStatsResetRE = ReplicatedStorage:WaitForChild("PlayerStatsResetRE")
local ResetInventoryBE = ReplicatedStorage:WaitForChild("InventoryEventsNew"):WaitForChild("ResetInventoryBE")
local ResetIngredientBE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("ResetIngredientsEvent")

PlayerStatsResetRE.OnServerEvent:Connect(function(player)
    GameStatsUtilities.initializePlayerGameStats(player)
	LevelSystem.Reset(player)

	QuestTrackerUtilities.initializePlayerQuestData(player)

    ResetInventoryBE:Fire(player)

    ResetIngredientBE:Fire(player)

    CheckpointUtilities.initializeCheckpoints(player, {})
	player:SetAttribute("current_checkpoint", -1)
    -- Keel the player
    wait(1.5)
    player:Kick("You have reset your stats! Rejoin to see effect")
end)