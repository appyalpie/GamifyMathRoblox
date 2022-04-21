local ServerStorage = game:GetService("ServerStorage")
local overheadName = ServerStorage.Titles:WaitForChild("overheadName")
local overheadTitle = ServerStorage.Titles:WaitForChild("overheadTitle")
local titleModule = require(game.ServerScriptService:WaitForChild("TitleModule"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TitleDataStore = DataStoreService:GetDataStore("TitleDataStore")
local CurrentTitleDataStore = DataStoreService:GetDataStore("CurrentTitleDataStore")


local ShowTitlesEvent = ReplicatedStorage.RemoteEvents.Titles:FindFirstChild('ShowTitlesEvent')
local InitTitlesEvent = ReplicatedStorage.RemoteEvents.Titles:FindFirstChild('InitTitlesEvent')
local ActivateTitleButtonEvent = ReplicatedStorage.RemoteEvents.Titles:FindFirstChild('ActivateTitleButtonEvent')


--TODO: Make sure this is only called when player enters the server
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)

        local textButton = ServerStorage:WaitForChild("InventoryScrollingButtonBasic"):Clone()
        textButton.Parent = ReplicatedStorage

        local IDs

        -- First call to datastore to fetch title IDs tied to userID
        local success, errorMessage = pcall(function()
            IDs = TitleDataStore:GetAsync(player.UserId)
        end)
    
        if success then
            print("First Title GetAsync Success")
        else
            print("Error: " .. errorMessage)
        end

        -- if IDs is nil, we create an entry in the datastore with {0} as the default titleID value
        -- 0 isn't a title ID, so it's kind of just empty data, but helps avoid a lot of issues
        -- where data retrieved from GetAsyc was nil
        if IDs == nil then
            local success, errorMessage = pcall(function()
                TitleDataStore:SetAsync(player.UserId, {0, 4})
                IDs = {0, 4}
            end)
        
            if success then
                print("Initial data store created")
            else
                print("Error: " .. errorMessage)
            end
        end

        local PastSelectedTitle = titleModule.GetCurrentlySelectedTitle(player)
        if PastSelectedTitle == nil then
            local success, errorMessage = pcall(function()
                PastSelectedTitle = CurrentTitleDataStore:GetAsync(player.UserId)
            end)
        
            if success then
                print("PastSelectedTitle GetAsync Success")
            else
                print("Error: " .. errorMessage)
            end
        end
     
        -- This is the format that is stored on the server to avoid using dataStore calls
        local onlinePlayerEntry = {
            userId = player.UserId,
            IDs = IDs,
            currentlySelectedTitle = PastSelectedTitle
        }

        print(onlinePlayerEntry)

        -- Store currently active online player titles. This helps cut down on datastore calls by
        -- copying the data to the server.
        titleModule.StoreOnlinePlayerTitles(onlinePlayerEntry)

        -- send the initial titles to the current player
        InitTitlesEvent:FireClient(player, titleModule.ParseTitleIDs(titleModule.GetUserTitles(player.UserId)))

        ActivateTitleButtonEvent:FireClient(player, PastSelectedTitle)

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
        --for i = 1, #titleArray do
        --    overheadTitleClone.TextLabel.Text = (titleArray[i])
        --    wait(5)
        --end

    end)
end)


game.Players.PlayerRemoving:Connect(function(player)

    -- take the server data and store it through dataStore
    local success, errorMessage = pcall(function()
        TitleDataStore:SetAsync(player.UserId, titleModule.GetUserTitles(player.UserId))
    end)
    
    if success then
        print("Title data stored upon player remove")
    else
        print("Error: " .. errorMessage)
    end

    local success, errorMessage = pcall(function()
        CurrentTitleDataStore:SetAsync(player.UserId, titleModule.GetCurrentlySelectedTitle(player))
    end)

    if success then
        print("Current selected title stored")
    else
        print("Error: " .. errorMessage)
    end
    
    -- Remove the entry on the server when the player leaves because they are no longer active
    titleModule.RemoveOnlinePlayerTitles(player.UserId)



end)

local function onShowTitlesEvent(player, title)
    overheadTitle = game.Workspace:WaitForChild(player.name):WaitForChild("Head"):WaitForChild("overheadTitle")
    overheadTitle.TextLabel.Text = title
    titleModule.SetCurrentlySelectedTitle(player, title)
end

ShowTitlesEvent.OnServerEvent:Connect(onShowTitlesEvent)