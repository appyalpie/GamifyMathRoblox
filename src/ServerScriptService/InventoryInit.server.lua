local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
 

--attachs inventory item after checking if inventory data exist
Players.PlayerAdded:Connect (function (player)

    local functions = player:WaitForChild("PlayerScripts",10):WaitForChild("Inventory",10):WaitForChild("functions",10)
    local savedInventory -- nil
    local success = pcall(function()
        savedInventory = dataStore:GetAsync(player.InvData)
    end)
    local Inventory 
    if success then
        Inventory = functions.Inventory.new(savedInventory)
    else
        Inventory = functions.Inventory.new()
    end
     functions.store(Inventory)
   
end)
--triggers the Save Command
Players.PlayerRemoving:Connect(function(player)
local functions = player.PlayerScripts.Inventory.functions

local Inventory = functions.Inventory.Save(player)
    pcall(function()
    dataStore:SetAsync(player.InvData, Inventory)
    end)
end)