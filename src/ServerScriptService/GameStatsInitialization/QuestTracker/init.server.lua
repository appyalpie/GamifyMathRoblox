local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

------ DataStoreData ------
local PlayerQuestDataStore = DataStoreService:GetDataStore("PlayerQuestData")

------ Module ------
local QuestTrackerUtilities = require(script.QuestTrackerUtilities)

------ Remote Events (Update and Handshake) ------
local QuestTrackerUpdateRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateRE")
local QuestTrackerUpdateReadyRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateReadyRE")
local QuestTrackerUpdateQuestRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateQuestRE")
local QuestNPCUpdateRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestNPCUpdateRE")

------ Bindable Event (Update when updated) ------
local QuestTrackerUpdateBE = script:WaitForChild("QuestTrackerUpdateBE")
local QuestTrackerStatsSyncBE = script:WaitForChild("QuestTrackerStatsSyncBE")
local QuestTrackerStatsSyncReadyBE = script:WaitForChild("QuestTrackerStatsSyncReadyBE")

------ Update the QuestTracker Once the player's QuestTracker GUI Loads (Occurs once) ------
QuestTrackerUpdateReadyRE.OnServerEvent:Connect(function(player)
    ------ Get Saved Quest Information (if any)
    local success, returnedValue = pcall(function()
        return PlayerQuestDataStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or type(returnedValue) ~= "table" then
            QuestTrackerUtilities.initializePlayerQuestData(player)
        else
            QuestTrackerUtilities.setQuestDataStatus(player, returnedValue)
        end
    else -- Possible datastore throttle error
        QuestTrackerUtilities.initializePlayerQuestData(player)
    end

    ------ If the player has not completed the first quest, then set the first quest active ------
    QuestTrackerUtilities.updateStatus(player, 1, "active")

    ------ Allow Player to Update QuestTracker with Information ------
    QuestTrackerUtilities.printQuestData(player)
    QuestTrackerStatsSyncReadyBE:Fire(player)
end)

Players.PlayerRemoving:Connect(function(player)
    QuestTrackerUtilities.printQuestData(player)
    local playerQuestData = QuestTrackerUtilities.getPlayerQuestData(player)
    local success, errorMessage = pcall(function()
        PlayerQuestDataStore:SetAsync(player.UserId, playerQuestData)
    end)
    if not success then
        print(errorMessage)
    end
end)


QuestTrackerUpdateBE.Event:Connect(function(player, questIndex, status, amount)
    if status ~= nil then
        QuestTrackerUtilities.updateStatus(player, questIndex, status)
    end
    if amount ~= nil then
        QuestTrackerUtilities.updateAmount(player, questIndex, amount)
    end
    QuestTrackerUpdateRE:FireClient(player, QuestTrackerUtilities.getPlayerQuestData(player))
end)

QuestTrackerStatsSyncBE.Event:Connect(function(player, gameStatsData)
    print("Updating Game Stats for Quest Tracker")
    QuestTrackerUtilities.gameStatsUpdate(player, gameStatsData)
    
    ------ Allow Player to Update QuestNPC Statuses with Information ------
    QuestNPCUpdateRE:FireClient(player, QuestTrackerUtilities.getPlayerQuestData(player))

    ------ Allow Player to Update QuestTracker with Information ------
    QuestTrackerUpdateRE:FireClient(player, QuestTrackerUtilities.getPlayerQuestData(player))
end)

QuestTrackerUpdateQuestRE.OnServerEvent:Connect(function(player, questIndex, status)
    print(tostring(player) .. " " .. tostring(questIndex) .. " " .. tostring(status))
    QuestTrackerUtilities.updateStatus(player, questIndex, status)
    QuestTrackerUpdateRE:FireClient(player, QuestTrackerUtilities.getPlayerQuestData(player))
end)