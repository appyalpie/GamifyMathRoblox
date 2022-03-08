local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnlockBarrierRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("UnlockBarrierRE")

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
        Game24Last5Solutions = {}
    }
end

-----Overall Game------
GameStatsUtilities.incrementXP = function(player, amount)
    playerGameStats[player.UserId]["XP"] = playerGameStats[player.UserId]["XP"] + amount
end

GameStatsUtilities.incrementCurrency = function(player, amount)
    playerGameStats[player.UserId]["Currency"] = playerGameStats[player.UserId]["Currency"] + amount
end

-----Math Blocks------

-----24 Game------

GameStatsUtilities.incrementGame24Wins = function(player)
    playerGameStats[player.UserId]["Game24Wins"] = playerGameStats[player.UserId]["Game24Wins"] + 1
end

GameStatsUtilities.newGame24NPCDefeated = function(player, npcName)
    if table.find(playerGameStats[player.UserId]["Game24NPCDefeated"], npcName) ~= nil then
        return
    else
        print("Setting")
        table.insert(playerGameStats[player.UserId]["Game24NPCDefeated"], npcName)
        if #playerGameStats[player.UserId]["Game24NPCDefeated"] >= 1 then
            print("Firing")
            UnlockBarrierRE:FireClient(player)
        end
    end
end

GameStatsUtilities.getPlayerData = function(player)
    return playerGameStats[player.UserId]
end

GameStatsUtilities.saveLastSolution = function(player, solution)
    if #playerGameStats[player.UserId]["Game24Last5Solutions"] == 5 then
        table.remove(playerGameStats[player.UserId]["Game24Last5Solutions"], 5)
    end
    table.insert(playerGameStats[player.UserId]["Game24Last5Solutions"], 1, solution)
end


return GameStatsUtilities