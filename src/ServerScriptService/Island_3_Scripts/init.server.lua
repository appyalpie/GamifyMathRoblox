local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerIngredientStore = DataStoreService:GetDataStore("PlayerIngredientInventory")

local PotionUtilities = require(script.PotionUtilities)

--local InitPlayerInventoryEvent = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("GetPlayerInventoryEvent")
--local AddIngredientEvent = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("AddIngredientEvent")

Players.PlayerAdded:Connect(function(player)
    local success, returnedValue = pcall(function()
        return PlayerIngredientStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or type(returnedValue) ~= "table" then
            PotionUtilities.InitializePlayerIngredientInventory(player)
        else
            PotionUtilities.SetPlayerIngredients(player, returnedValue)
        end
    else -- Possible datastore throttle error
        PotionUtilities.InitializePlayerIngredientInventory(player)
    end
end)

-- when the player leaves, save their current ingredients
Players.PlayerRemoving:Connect(function(player)
    local playerIngredients = PotionUtilities.GetPlayerIngredients(player)
    local success, errorMessage = pcall(function()
        PlayerIngredientStore:SetAsync(player.UserId, playerIngredients)
    end)
    if not success then
        print(errorMessage)
    end
end)

