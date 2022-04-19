local titleModule = {}

titleModule.onlinePlayerTitleSets = {
    userId = "",
    idArray = {}
}

-- This is where all titles will be stored
-- IDs are simply the index in the array
-- (starts at index 1 cause lua)
titleModule.titles = 
{
    [1] = "Developer",
    [2] = "Explorer",
    [3] = "DJ",
    [4] = "Newbie",
    [5] = "Novice",
    [6] = "Apprentice",
    [7] = "Adept",
    [8] = "Maker",
    [9] = "Journymen",
    [10] = "Master"
}

-- Parses title IDs and turns them into a string array to be returned
titleModule.ParseTitleIDs = function(IDs)
    local titlesToReturn = {}
    if not IDs then
        return titlesToReturn
    end
    for i = 1, #IDs do
        if IDs[i] <= #titleModule.titles and IDs[i] > 0 then
            table.insert(titlesToReturn, titleModule.titles[IDs[i]])
        end
    end

    return titlesToReturn
end

-- Stores onlinePlayerTitleSets objects into the server
titleModule.StoreOnlinePlayerTitles = function(playerTitleSetToAdd)
    table.insert(titleModule.onlinePlayerTitleSets, playerTitleSetToAdd)
end

-- Removes onlinePlayerTitleSets objects from server
-- TODO: test the heck out of this, I think it's broken
titleModule.RemoveOnlinePlayerTitles = function(playerId)
    for key, value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == playerId then
            table.remove(value, key)
        end
    end
end

-- Returns array of user title IDs tied to a playerID
titleModule.GetUserTitles = function(playerId)
    for key, value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == playerId then
            return value.IDs
        end
    end

end

-- Adds title to a userID, then invokes the client to update its list of titles
-- titleModule.AddTitleToUser(player, int titleId)
titleModule.AddTitleToUser = function(player, titleId)
    local addTitlesEvent = game.ReplicatedStorage:FindFirstChild('AddTitlesEvent')
    for key,value in pairs(titleModule.onlinePlayerTitleSets) do
        if value.userId == player.UserId and not table.find(value.IDs, titleId) then
            table.insert(value.IDs, titleId)
            addTitlesEvent:FireClient(player, titleModule.titles[titleId])
        end
    end
end


return titleModule