local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
local functions = require(script.functions)

Players.PlayerAdded:Connect (function (Player)
    local Inventory = functions.Inventory.new(Player)
    -- connect to player GUI


    local savedInventory
    local success = pcall(function()
        savedInventory = dataStore:GetAsync(Player.InvData)
    end)
    if success then
        Inventory = savedInventory        
    end


end)
Players.PlayerRemoving:Connect(function(Player)
local Inventory = Player.Inventory
    pcall(function()
    dataStore:SetAsync(Player.InvData, Inventory)
    end)
end)