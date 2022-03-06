local titleModule = {}

titleModule.onlinePlayerTitleSets = {
    userId = "",
    idArray = {}
}

titleModule.titles = 
{
    "Developer",
    "Serf",
    "Merchant",
    "Professional",
    "Knight",
    "Baron",
    "Count",
    "Duke",
    "King"
}

titleModule.ParseTitleIDs = function(IDs)
    local titlesToReturn = {}
    if not IDs then
        return titlesToReturn
    end
    for i = 1, #IDs do
        if IDs[i] < #titleModule.titles and IDs[i] > 0 then
            table.insert(titlesToReturn, titleModule.titles[IDs[i]])
        end
    end

    return titlesToReturn
end

titleModule.StoreOnlinePlayerTitles = function(playerTitleSetToAdd)
    print(playerTitleSetToAdd)
    table.insert(titleModule.onlinePlayerTitleSets, playerTitleSetToAdd)
end

titleModule.RemoveOnlinePlayerTitles = function(playerId)
    for key, value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == playerId then
            table.remove(value, key)
        end
    end
end

titleModule.GetUserTitles = function(playerId)
    for key, value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == playerId then
            return value.IDs
        end
    end
end

titleModule.AddTitleToUser = function(player, titleId)
    local addTitlesEvent = game.ReplicatedStorage:FindFirstChild('AddTitlesEvent')
    for key,value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == player.UserId and not table.find(value.IDs, titleId) then
            table.insert(value.IDs, titleId)
            addTitlesEvent:FireClient(player)
        end
    end
end


return titleModule