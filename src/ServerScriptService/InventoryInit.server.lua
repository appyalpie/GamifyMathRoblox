local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryEvents",1)
--attachs inventory item after checking if inventory data exist

 
Players.PlayerAdded:Connect(function(player)
    -- Fire the remote event
    local savedInventory  = Instance.new("Folder")
    savedInventory.Name = "AcessoryInventory"
    savedInventory.Parent = player
    local Equipped = Instance.new("Folder")
    Equipped.Name = "Equipped"
    Equipped.Parent = player

    local head = Instance.new("StringValue")
    head.Name = "Head"
    head.Parent = Equipped
    local body = Instance.new("StringValue")
    body.Name = "Body"
    body.Parent = Equipped
    local legs = Instance.new("StringValue")
    legs.Name = "Legs"
    legs.Parent = Equipped
    local arms = Instance.new("StringValue")
    arms.Name = "Arms"
    arms.Parent = Equipped

    local success = pcall(function()
        savedInventory = dataStore:GetAsync(player.InvData)
    end)
    
    if success then
        remoteEvent:WaitForChild("InventoryStore"):FireClient(player,savedInventory)       
    end  
end)



--triggers the Save Command
Players.PlayerRemoving:Connect(function(player)
    local store = remoteEvent:WaitForChild("InventorySave")
    local DataToStore = store:FireClient(player)
    dataStore:SetAsync(player.InvData, DataToStore)

end)

