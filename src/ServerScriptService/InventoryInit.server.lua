local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Data")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryEvents",1)
local AccesoryTable = require(game.ServerScriptService:WaitForChild("AccessoryList"))

local addAccTable = Instance.new("RemoteEvent")
addAccTable.Parent = remoteEvent
addAccTable.Name = "AddAccesoryTableEvent"
-- is intended to add to the Physical accessory to the Player Character
-- this can be changed once Accessories are changed
local function equipAccessory(player,Accesory)
    local character = player.character
    if Accesory ~= nil and character ~= nil then
        if character:FindFirstChild(player.Name.."equipped" + Accesory.Type)  then
            character[player.Name.."equipped" + Accesory.Type]:Destroy() 
        end
        if character.HumanoidRootPart:FindFirstChild("attachmentCharacter") then
            character.HumanoidRootPart:FindFirstChild("attachmentCharacter"):Destroy()
        end

        Accesory.Name = player.Name.."equipped" + Accesory.Type
        Accesory:SetPrimaryPart(character.HumanoidRootPart.CFrame)

        local modelSize = Accesory.PrimaryPart.Size

        local attachmentCharacter = Instance.new("Attachment")
        attachmentCharacter.Visible = false
        attachmentCharacter.Name = "attachmentCharacter"
        attachmentCharacter.Parent = character.HumanoidRootPart
        attachmentCharacter.Position = Vector3.new(0,0,0) + modelSize

        local attachmentAccessory = Instance.new("Attachment")
        attachmentAccessory.Visible = false
        attachmentAccessory.Parent = Accesory.PrimaryPart
        

        local alignPosition = Instance.new("AlignPosition")
        alignPosition.MaxForce = 25000
        alignPosition.Attachment0 = attachmentAccessory
        alignPosition.Attachment1 = attachmentCharacter
        alignPosition.Responsiveness = 25
        alignPosition.Parent = Accesory

        local alignOrientation = Instance.new("AlignOrientation")
        alignOrientation.Attachment0 = attachmentAccessory
        alignOrientation.Attachment1 = attachmentCharacter
        alignOrientation.Parent = Accesory

        
        Accesory.Parent = character
        end

end
 -- creates the Equipped Folder inside of player with string locations

Players.PlayerAdded:Connect(function(player)
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
    wait(1)
    addAccTable:FireClient(AccesoryTable)
    
    local success = pcall(function()
        savedInventory = dataStore:GetAsync(player.InvData)
    end)
    
    if success then
        remoteEvent:WaitForChild("InventoryStore"):FireClient(player,savedInventory)       
    end  
    -- set of changed events which updates changed Equipped Slot
   
    Equipped.Head.Changed:Connect(function()
        if Equipped.Head.Value ~= nil then
            if game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Head.Value) then
                equipAccessory(player,game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Head.Value):Clone())
            end
        end
    end)
    Equipped.Body.Changed:Connect(function()
        if Equipped.Body.Value ~= nil then
            if game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Body.Value) then
                equipAccessory(player,game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Body.Value):Clone())
            end
        end
    end)
    Equipped.Arms.Changed:Connect(function()
        if Equipped.Arms.Value ~= nil then
            if game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Arms.Value) then
                equipAccessory(player,game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Arms.Value):Clone())
            end
        end
    end)
    Equipped.Legs.Changed:Connect(function()
        if Equipped.Legs.Value ~= nil then
            if game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Legs.Value) then
                equipAccessory(player,game.ReplicatedStorage:WaitForChild("Accessories"):FindFirstChild(Equipped.Legs.Value):Clone())
            end
        end
    end)

    
end)



--triggers the Save Command
Players.PlayerRemoving:Connect(function(player)
    local store = remoteEvent:WaitForChild("InventorySave")
    local DataToStore = store:FireClient(player) -- <-- this fires the InventorySave Event in the player timing may need adjustments
    dataStore:SetAsync(player.InvData, DataToStore)

end)
-- updates the Players Equipped so equipped accessories shows up in the servers
remoteEvent.InventoryEquip.OnServerEvent:Connect(function(player, AccessoryName)
    local accessory = game.ReplicatedStorage.AccessoryList:FindFirstChild(AccessoryName)

    if accessory and player.AcessoryInventoryFindFirstChild(AccessoryName) then
        player.Equipped[AccessoryName.Parent.Type] = AccessoryName
    end

end)

local remoteServerFunction = Instance.new("RemoteFunction")
remoteServerFunction.Parent = ReplicatedStorage
remoteServerFunction.Name = "remoteServerFunction"

local function SendtoServer(player, InvData)
    for name in pairs(InvData) do
        table.insert(player.AccesoryInventory,InvData)
        player.AccesoryInventory[name].Value = InvData[name].Value
    end
    return player.AccesoryInventory
end

remoteServerFunction.OnServerInvoke = SendtoServer


