local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InventoryItemInformation = require(ReplicatedStorage:WaitForChild("InventoryItemInformation"))
local ShopItemsInformation = require(ReplicatedStorage:WaitForChild("ShopItemsInformation"))
local GameStatsUtilities = require(script.Parent.GameStatsInitialization.GameStatsUtilities)

local InventoryInformationRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryInformationRF")
local InventoryEquipRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryEquipRF")
local InventoryUnequipRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryUnequipRF")
local ShopPurchaseRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("ShopPurchaseRF")
local ResetInventoryBE = ReplicatedStorage.InventoryEventsNew:WaitForChild("ResetInventoryBE")

local InventoryDataStore = DataStoreService:GetDataStore("PlayerInventories")

local PlayerInventoryTable = {}

-- K:[player.UserId] V: String Table
local PlayerEquippedItems = {}

------ Restore Past Inventory (if any) ------
Players.PlayerAdded:Connect(function(player)
    local success, returnedValue = pcall(function()
        return InventoryDataStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or type(returnedValue) ~= "table" then
            PlayerInventoryTable[player.UserId] = {}
        else
            PlayerInventoryTable[player.UserId] = returnedValue
        end
    else -- Possible datastore throttle error
        PlayerInventoryTable[player.UserId] = {}
    end
    --PlayerInventoryTable[player.UserId] = {"MathBlockHead", "PirateHat","TwoDeckKneeCover"}
    
    ------ Re-equip Accessories for the Player When They Spawn ------
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        if player:FindFirstChild("EquipmentFolder") then
            for _, v in pairs(player:FindFirstChild("EquipmentFolder"):GetChildren()) do
                print(v.Name)
                humanoid:AddAccessory(v:Clone())
            end
        end
    end)
end)

------ Save Inventory on Leave ------
Players.PlayerRemoving:Connect(function(player)
    local playerData = PlayerInventoryTable[player.UserId]
    local success, errorMessage = pcall(function()
        InventoryDataStore:SetAsync(player.UserId, playerData)
    end)
    if not success then
        print(errorMessage)
    end
end)

local Accessories_List = ServerStorage:WaitForChild("Accessories_New")
------ Get Player's Inventory Information ------

------ Initialize Player Equipment Folder (if not yet Initialized) ------
local function initializePlayerEquipmentFolder(player)
	if player:FindFirstChild("EquipmentFolder") == nil then
		local EquipmentFolder = Instance.new("Folder")
		EquipmentFolder.Name = "EquipmentFolder"
		EquipmentFolder.Parent = player
	end
end

InventoryInformationRF.OnServerInvoke = function(player)
    initializePlayerEquipmentFolder(player)
    return PlayerInventoryTable[player.UserId]
end

------ Equip An Accessory for a player ------
InventoryEquipRF.OnServerInvoke = function(player, itemButton)
    print("Server has been invoked")
    local Accessory = Accessories_List:WaitForChild(itemButton:GetAttribute("item_name"))
    local newAccessoryForFolder = Accessory:Clone()
    newAccessoryForFolder.Parent = player:FindFirstChild("EquipmentFolder")
    local newAccessoryToEquip = Accessory:Clone()

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:AddAccessory(newAccessoryToEquip)
    return true
end

------ Unequip an Accessory for a player ------
InventoryUnequipRF.OnServerInvoke = function(player, itemType)
    print("Server has been invoked")
    for _, v in pairs(player:FindFirstChild("EquipmentFolder"):GetChildren()) do
        if InventoryItemInformation[v.Name].Type == itemType then
            v:Destroy()
        end
    end
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    for _, v in pairs(humanoid:GetAccessories()) do
        if InventoryItemInformation[v.Name] and InventoryItemInformation[v.Name].Type == itemType then
            v:Destroy()
        end
    end
    return true
end

------ Add an Accessory to the Player's Inventory ------
ShopPurchaseRF.OnServerInvoke = function(player, Shopkeeper, itemName)
    --[[
        1. Get Player's Currency
        2. Check
        3. Decrement
        4. Add to Player's Inventory
    ]]
    local playerCurrentCurrency = GameStatsUtilities.getPlayerData(player)["Currency"]
    print("Player Currency: " .. playerCurrentCurrency)
    local cost = ShopItemsInformation[Shopkeeper][itemName].Cost
    if playerCurrentCurrency >= cost then
        GameStatsUtilities.incrementCurrency(player, -cost)
        table.insert(PlayerInventoryTable[player.UserId], itemName)
        print("Added Item to Inventory")
        return true
    else
        return false
    end
end

ResetInventoryBE.Event:Connect(function(player)
    PlayerInventoryTable[player.UserId] = {}

end)