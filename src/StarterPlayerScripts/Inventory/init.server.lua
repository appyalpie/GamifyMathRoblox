local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
local functions = require(script.functions)

--attachs inventory item after checking if inventory data exist
Players.PlayerAdded:Connect (function (player)

    -- connect to player GUI
    local savedInventory
    local success = pcall(function()
        savedInventory = dataStore:GetAsync(player.InvData)
    end)
    Players:waitForChild("LocalPlayer")
    if success then
         functions.Inventory.new(player,savedInventory)
    else
        functions.Inventory.new(player,0)
    end

end)
--triggers the Save Command
Players.PlayerRemoving:Connect(function(Player)
local Inventory = Player.Inventory.Save(Player)
    pcall(function()
    dataStore:SetAsync(Player.InvData, Inventory)
    end)
end)