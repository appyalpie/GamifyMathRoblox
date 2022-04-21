local ServerScriptService = game:GetService("ServerScriptService")
local AwardBadgeBE = ServerScriptService.BadgesInitialization:WaitForChild("AwardBadgeBE")

local QuestTrackerUtilities = {}

local playerQuestData = {}

QuestTrackerUtilities.printQuestData = function(player)
    for _, v in pairs(playerQuestData[player.UserId]) do
        print(v.Status .. " " .. v.Title)
    end
end

QuestTrackerUtilities.initializePlayerQuestData = function(player)
    print("Quest Data Initialized")
    playerQuestData[player.UserId] = {
        [1] = {
            Index = 1,
            Status = "inactive",
            Title = "Pass the Math Blocks Challenge!",
            Description = "Get to the end!"
        },
        [2] = {
            Index = 2,
            Status = "inactive",
            Title = "Take Down the Barrier!",
            Description = "Defeat 24 Game Challengers:",
            Amount = 0,
            AmountRequired = 2
        },
        [3] = {
            Index = 3,
            Status = "inactive",
            Title = "A Hatless Pirate",
            Description = "Return the Hatless Pirate's Hat"
        },
        [4] = {
            Index = 4,
            Status = "inactive",
            Title = "Take Down the Barrier!",
            Description = "Help the Wizard with his Back..."
        }
    }
end

QuestTrackerUtilities.setQuestDataStatus = function(player, questData)
    QuestTrackerUtilities.initializePlayerQuestData(player)
    for k, v in pairs(questData) do
        playerQuestData[player.UserId][k].Status = questData[k].Status
    end
end

QuestTrackerUtilities.updateStatus = function(player, questIndex, status)
    if playerQuestData[player.UserId][questIndex].Status == "completed" then return end
    playerQuestData[player.UserId][questIndex].Status = status
    if status == "completed" then
        if questIndex == 1 then
            AwardBadgeBE:Fire(player, "MathBlocksBadge")
        elseif questIndex == 2 then
            AwardBadgeBE:Fire(player, "ChallengerBadge")
        elseif questIndex == 3 then
            print("No badge yet")
        elseif questIndex == 4 then
            AwardBadgeBE:Fire(player, "WizardBadge")
        end
    end
end

QuestTrackerUtilities.updateAmount = function(player, questIndex, amount)
    playerQuestData[player.UserId][questIndex].Amount = amount
end

QuestTrackerUtilities.getPlayerQuestData = function(player)
    return playerQuestData[player.UserId]
end

QuestTrackerUtilities.gameStatsUpdate = function(player, gameStatsData)
    playerQuestData[player.UserId][2].Amount = #gameStatsData["Game24NPCDefeated"]
    if gameStatsData["BarrierToIsland3Down"] == true then
        playerQuestData[player.UserId][2].Status = "completed"
    end
    if gameStatsData["BarrierToIsland4Down"] == true then
        playerQuestData[player.UserId][4].Status = "completed"
    end
end

return QuestTrackerUtilities