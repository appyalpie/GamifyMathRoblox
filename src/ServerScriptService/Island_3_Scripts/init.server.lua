local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerIngredientStore = DataStoreService:GetDataStore("PlayerIngredientInventory")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts.PotionCreation:WaitForChild("PotionUtilities"))
local IngredientSpawnUtilities = require(ServerScriptService.Island_3_Scripts.IngredientSpawns:WaitForChild("IngredientSpawnUtilities"))

--Initiate ingredient spawning on the islands
IngredientSpawnUtilities.initialize()

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

