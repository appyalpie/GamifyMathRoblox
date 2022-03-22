local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("InvData")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryEvents",1)

if not(game.ReplicatedStorage:FindFirstChild('Accessories')) then
    local accessoryFolder = ServerStorage:WaitForChild("Accessories")
    local clone = accessoryFolder:Clone()
    clone.Parent = ReplicatedStorage
end

local AccessoryListModule = require(ServerScriptService:WaitForChild("AccessoryList"))
local AccessoryList = AccessoryListModule.GetAccesory()

local addAccTable = remoteEvent.AddAccesoryTableEvent
local SaveTable = remoteEvent.InventorySave
local remoteFunctionEquip = remoteEvent:FindFirstChild("SendEquippedToServer")

local ColorEvent = remoteEvent:WaitForChild("ColorEvent")


local InvTable = {
    
}

 -- creates the Equipped Folder inside of player with string locations
Players.PlayerAdded:Connect(function(player)
    local savedInventoryClient  = Instance.new("Folder")
    savedInventoryClient.Name = "AccessoryInventory"
    savedInventoryClient.Parent = player
    local Equipped = Instance.new("Folder")
    Equipped.Name = "Equipped"
    Equipped.Parent = player

    local Item = Instance.new("Accessory")
    Item.Name = "Slot"

    local head = Instance.new("StringValue")
    head.Name = "Head"
    head.Parent = Equipped
    Item:Clone().Parent = head

    local body = Instance.new("StringValue")
    body.Name = "Body"
    body.Parent = Equipped
    Item:Clone().Parent = body

    local legs = Instance.new("StringValue")
    legs.Name = "Legs"
    legs.Parent = Equipped
    Item:Clone().Parent = legs

    local arms = Instance.new("StringValue")
    arms.Name = "Arms"
    arms.Parent = Equipped
    Item:Clone().Parent = arms


    wait(1)
    local success, savedInventory = pcall(function()
        return dataStore:GetAsync(player.UserId)
    end)
    if savedInventory == nil then
        success = false
    end
    print(savedInventory)
    
    savedInventory = {} -- ONCE SHOP GUI IS SET UP DELETE THIS LINE

    -- creates an index on the server using the player.UserId as a key stores the saved Inventory set of strings
    table.insert(InvTable, player.UserId, savedInventory)
    -- passes player and accessory table
    -- wait is here so all client scripts can finish loading in otherwise they don't fire shop GUI sometimes
    wait(1)
    addAccTable:FireClient(player,AccessoryList) 

    if success then
        local store = remoteEvent:WaitForChild("InventoryStore")
        store:FireClient(player, savedInventory)
        print("Data Retrieved")   

    else
        if not savedInventory then
        local success, error = pcall(function()
        dataStore:setAsync(player.UserId, {})
        end)
        if success then
            print("Data Table created")
        else
            print("Error :" .. error)
        end
        end
    end
    -- makes sure Slots return to empty on player death as death resets accessories
    player.CharacterRemoving:Connect(function(Character)
        local loadout = Players:GetPlayerFromCharacter(Character)
        loadout = loadout.Equipped:GetChildren()
        for key in pairs(loadout) do
            if loadout[key]:GetChildren()[1].Name ~= "Slot"then
                loadout[key]:GetChildren()[1].Name = "Slot"
                
            end
        end
    end)
end)
-- updates the UserId index table
function GetTable(player, DataToStore)
    table.insert(InvTable,player.UserId,DataToStore)
end

--[[Saves to Data Store, Data put in the field cannot occur here]]
Players.PlayerRemoving:Connect(function(player)
    local Data 
    Data = InvTable[player.UserId]
    print(Data) -- <-- this fires the InventorySave Event in the player timing may need adjustments
    local success, ErrorMessage = pcall(function()
        dataStore:SetAsync(player.UserId, Data)
    end)
    if success then
        print("Player Data saved for" .. player.UserId)
    else
        print("Error : " .. ErrorMessage)
    end

end)
-- updates the Players Equipped so equipped accessories shows up in the servers
-- change the ToBeEquipped to accessory 
function EquipToPlayer(player, ToBeEquipped, Type)
    local attach = player.Character.Humanoid
    local loadout = player.Equipped:GetChildren()
    for key in pairs(loadout) do
        if loadout[key]:GetChildren()[1].Name ~= "Slot" and loadout[key].Name == Type then
            if loadout[key]:GetChildren()[1].Name == ToBeEquipped.Parent.Name then
                attach.Parent:FindFirstChild(loadout[key]:GetChildren()[1].Name):Destroy()
                loadout[key]:GetChildren()[1].Name = "Slot"
                return 0 -- stops if it is accessory to be UnEquipped
            else
                attach.Parent:FindFirstChild(loadout[key]:GetChildren()[1].Name):Destroy()
                loadout[key]:GetChildren()[1].Name = "Slot"
            end
        end
    end
    
   -- clones Accessory to player character
    for key in pairs(loadout) do
        if loadout[key].Name == Type then
            local slot = ToBeEquipped:Clone()
            slot.Parent = loadout[key]
            slot.Name = ToBeEquipped.Parent.Name
            loadout[key]:GetChildren()[1].Name = ToBeEquipped.Parent.Name
            attach:AddAccessory(slot)           
        end
    end
    SaveTable:FireClient(player)
end


-- clients Invoke Server to change Accessories
remoteFunctionEquip.OnServerInvoke = EquipToPlayer

SaveTable.OnServerEvent:Connect(GetTable) 

local function ClientColor(player,ItemName)
    ColorEvent:FireClient(player,ItemName)
end
ColorEvent.onServerEvent:Connect(ClientColor)