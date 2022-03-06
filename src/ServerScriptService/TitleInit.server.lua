local ServerStorage = game:GetService("ServerStorage")
local overheadName = ServerStorage.Titles:WaitForChild("overheadName")
local overheadTitle = ServerStorage.Titles:WaitForChild("overheadTitle")
local titleModule = require(game.ServerScriptService:WaitForChild("TitleModule"))

local DataStoreService = game:GetService("DataStoreService")
local TitleDataStore = DataStoreService:GetDataStore("TitleDataStore")

if not(game.ReplicatedStorage:FindFirstChild('GetTitlesEvent')) then
    Instance.new("RemoteFunction", game.ReplicatedStorage).Name = 'GetTitlesEvent'
end

if not(game.ReplicatedStorage:FindFirstChild('AddTitlesEvent')) then
    Instance.new("RemoteEvent", game.ReplicatedStorage).Name = 'AddTitlesEvent'
end

local getTitlesEvent = game.ReplicatedStorage:FindFirstChild('GetTitlesEvent')

--TODO: Make sure this is only called when player enters the server
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)

        local IDs = {0}

        -- First call to datastore to fetch title IDs tied to userID
        local success, errorMessage = pcall(function()
            local IDs = TitleDataStore:GetAsync(player.UserId)
        end)
    
        if success then
            print("data saved")
        else
            print("Error: " .. errorMessage)
        end

        -- if IDs is nil, we create an entry in the datastore with {0} as the default titleID value
        -- 0 isn't a title ID, so it's kind of just empty data, but helps avoid a lot of issues
        -- where data retrieved from GetAsyc was nil
        if not IDs then
            local success, errorMessage = pcall(function()
                TitleDataStore:SetAsync(player.UserId, {0})
            end)
        
            if success then
                print("Initial data store created")
            else
                print("Error: " .. errorMessage)
            end


        end

        -- This is the format that is stored on the server to avoid using dataStore calls
        local onlinePlayerEntry = {
            userId = player.UserId;
            IDs = IDs
        }

        -- Store currently active online player titles. This helps cut down on datastore calls by
        -- copying the data to the server.
        titleModule.StoreOnlinePlayerTitles(onlinePlayerEntry)
        
        -- we can set a billboardgui to display the player titles above their head
        -- on the server side of the game. So we parse title IDs for use in the billboard gui
        local titleArray = titleModule.ParseTitleIDs(titleModule.GetUserTitles(player.UserId))

        -- Clone both the overheadTitle and overheadName. The title sits above the name.
        local overheadTitleClone = overheadTitle:Clone()
        local overheadNameClone = overheadName:Clone()
        -- we wait for the clone to finish I think? The code has a hard time functioning w/o this
        wait(1)
        overheadNameClone.Parent = character.Head
        overheadTitleClone.Parent = character.Head
        -- This removes the default names above players heads that roblox has
        character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        overheadNameClone.TextLabel.Text = (player.name)

        -- Cycle through player titles just because. This will change to some sort of
        -- remote function once the UI is implemented
        for i = 1, #titleArray do
            overheadTitleClone.TextLabel.Text = (titleArray[i])
            wait(5)
        end

    end)
end)


game.Players.PlayerRemoving:Connect(function(player)

    -- take the server data and store it through dataStore
    local success, errorMessage = pcall(function()
        TitleDataStore:SetAsync(player.UserId, titleModule.GetUserTitles(player.UserId))
    end)

    -- Remove the entry on the server when the player leaves because they are no longer active
    titleModule.RemoveOnlinePlayerTitles(player.UserId)

    if success then
        print("data saved")
    else
        print("Error: " .. errorMessage)
    end


end)

-- Covers the server invoke for when we want to get all titles
local function onGetTitlesEvent(player)
    return titleModule.ParseTitleIDs(titleModule.GetUserTitles(player.UserId))
end

getTitlesEvent.OnServerInvoke = onGetTitlesEvent

