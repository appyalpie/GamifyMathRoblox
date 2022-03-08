local GameStatsUtilities = {}

local playerGameStats = {}

GameStatsUtilities.initializePlayerGameStats = function(player)
    playerGameStats[player.UserId] = {
        ------Overall Game------
        XP = 0,
        Currency = 0,
        ------Math Blocks------
        --BlocksCombined = 0,
        AddBlockCombinations = 0,
        SubtractBlocksCombined = 0,
        MultiplyBlocksCombined = 0,
        DivideBlocksCombined = 0,
        --FavoriteBlock = "Add",
        ------24 Game------
        Game24Wins = 0,
        Game24NPCDefeated = {},
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
    if playerGameStats[player.UserId]["Game24NPCDefeated"][npcName] then
        return
    else
        playerGameStats[player.UserId]["Game24NPCDefeated"][npcName] = true
    end
end

GameStatsUtilities.saveLastSolution = function(player, solution)
    table.insert(playerGameStats[player.UserId]["Game24Last5Solutions"], solution)
end


return GameStatsUtilities