local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnlockBarrierRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("UnlockBarrierRE")
local UnlockIsland3BarrierRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("UnlockIsland3BarrierRE")
local PortalGuiUpdateRE = ReplicatedStorage.RemoteEvents:WaitForChild("PortalGuiUpdateRE")
local LevelSystem = require(script.Parent.Parent.Utilities.LevelSystem)

local GameStatsUtilities = {}

local playerGameStats = {}

GameStatsUtilities.initializePlayerGameStats = function(player)
    print("Game Stats Initialized")
    playerGameStats[player.UserId] = {
        ------Overall Game------
        XP = 0,
        Currency = 0,
        ------Math Blocks------
        --BlocksCombined = 0,
        AddBlocksCombined = 0,
        SubtractBlocksCombined = 0,
        MultiplyBlocksCombined = 0,
        DivideBlocksCombined = 0,
        --FavoriteBlock = "Add",
        ------24 Game------
        Game24Wins = 0,
        Game24NPCDefeated = {},
        BarrierToIsland3Down = false,
        Game24Last5Solutions = {},
        ------Alchemy------
        BarrierToIsland4Down = false
    }
end

GameStatsUtilities.setPlayerGameStats = function(player, playerData)
    GameStatsUtilities.initializePlayerGameStats(player)
    playerGameStats[player.UserId]["XP"] = playerData["XP"]
    playerGameStats[player.UserId]["Currency"] = playerData["Currency"]
    playerGameStats[player.UserId]["AddBlocksCombined"] = playerData["AddBlocksCombined"]
    playerGameStats[player.UserId]["SubtractBlocksCombined"] = playerData["SubtractBlocksCombined"]
    playerGameStats[player.UserId]["MultiplyBlocksCombined"] = playerData["MultiplyBlocksCombined"]
    playerGameStats[player.UserId]["DivideBlocksCombined"] = playerData["DivideBlocksCombined"]
    playerGameStats[player.UserId]["Game24Wins"] = playerData["Game24Wins"]
    playerGameStats[player.UserId]["Game24NPCDefeated"] = playerData["Game24NPCDefeated"]
    playerGameStats[player.UserId]["BarrierToIsland3Down"] = playerData["BarrierToIsland3Down"]
    if playerData["BarrierToIsland3Down"] == true then
        UnlockBarrierRE:FireClient(player)
        PortalGuiUpdateRE:FireClient(player, true)
    end
    playerGameStats[player.UserId]["Game24Last5Solutions"] = playerData["Game24Last5Solutions"]
    playerGameStats[player.UserId]["BarrierToIsland4Down"] = playerData["BarrierToIsland4Down"]
    if playerData["BarrierToIsland4Down"] == true then
        UnlockIsland3BarrierRE:FireClient(player)
    end
end

-----Overall Game------
GameStatsUtilities.incrementXP = function(player, amount)
    if player then
        playerGameStats[player.UserId]["XP"] = playerGameStats[player.UserId]["XP"] + amount
        LevelSystem.SetLevelUpdate(player,playerGameStats[player.UserId]["XP"]) 
    end
end

GameStatsUtilities.incrementCurrency = function(player, amount)
    if player then
        playerGameStats[player.UserId]["Currency"] = playerGameStats[player.UserId]["Currency"] + amount
    end
end

-----Math Blocks------

GameStatsUtilities.incrementAddBlocksCombined = function(player)
    if player then
        playerGameStats[player.UserId]["AddBlocksCombined"] = playerGameStats[player.UserId]["AddBlocksCombined"] + 1
    end
end

GameStatsUtilities.incrementSubtractBlocksCombined = function(player)
    if player then
        playerGameStats[player.UserId]["SubtractBlocksCombined"] = playerGameStats[player.UserId]["SubtractBlocksCombined"] + 1
    end
end

GameStatsUtilities.incrementMultiplyBlocksCombined = function(player)
    if player then
        playerGameStats[player.UserId]["MultiplyBlocksCombined"] = playerGameStats[player.UserId]["MultiplyBlocksCombined"] + 1
    end
end

GameStatsUtilities.incrementDivideBlocksCombined = function(player)
    if player then
        playerGameStats[player.UserId]["DivideBlocksCombined"] = playerGameStats[player.UserId]["DivideBlocksCombined"] + 1
    end
end

-----24 Game------

GameStatsUtilities.incrementGame24Wins = function(player)
    playerGameStats[player.UserId]["Game24Wins"] = playerGameStats[player.UserId]["Game24Wins"] + 1
end

GameStatsUtilities.newGame24NPCDefeated = function(player, npcName)
    if table.find(playerGameStats[player.UserId]["Game24NPCDefeated"], npcName) ~= nil then
        return
    else
        --print("Setting")
        table.insert(playerGameStats[player.UserId]["Game24NPCDefeated"], npcName)
        if #playerGameStats[player.UserId]["Game24NPCDefeated"] >= 1 then
            --print("Firing")
            playerGameStats[player.UserId]["BarrierToIsland3Down"] = true
            UnlockBarrierRE:FireClient(player)
            PortalGuiUpdateRE:FireClient(player, true)
        end
    end
end

GameStatsUtilities.getPlayerData = function(player, returnLevelStatsBool)
    local returnLevelStatsBool = returnLevelStatsBool or false -- to allow for nil to be passed in
    if returnLevelStatsBool then
        return playerGameStats[player.UserId], GameStatsUtilities.getLevelInformation(player)
    else
        return playerGameStats[player.UserId]
    end
end

GameStatsUtilities.saveLastSolution = function(player, solution)
    if #playerGameStats[player.UserId]["Game24Last5Solutions"] == 5 then
        table.remove(playerGameStats[player.UserId]["Game24Last5Solutions"], 5)
    end
    table.insert(playerGameStats[player.UserId]["Game24Last5Solutions"], 1, solution)
end

------ Level System Stuff For Client Stats GUI ------
GameStatsUtilities.getLevelInformation = function(player)
    local playerLevel = LevelSystem.DisplayLevel(player)
    local playerLevelProgress = LevelSystem.DisplayProgression(player, playerGameStats[player.UserId]["XP"])
    local playerNextLevelAmount = LevelSystem.DisplayNextLevelAmount(player)
    return {playerLevel, playerLevelProgress, playerNextLevelAmount}
end

------ Island 3 Barrier Update ------
GameStatsUtilities.updateIsland3BarrierDown = function(player)
    playerGameStats[player.UserId]["BarrierToIsland4Down"] = true
end

return GameStatsUtilities