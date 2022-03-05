local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryStore",1)


--attachs inventory item after checking if inventory data exist

 
local function onPlayerAdded(player)
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
        remoteEvent:FireClient(player,savedInventory)       
    end  
end
Players.PlayerAdded:Connect(onPlayerAdded)


--triggers the Save Command
Players.PlayerRemoving:Connect(function(player)
--local functions = player.PlayerScripts.Inventory.functions

--local Inventory = functions.Inventory.Save(player)
  --  pcall(function()
    --dataStore:SetAsync(player.InvData, Inventory)
    --end)
end)

