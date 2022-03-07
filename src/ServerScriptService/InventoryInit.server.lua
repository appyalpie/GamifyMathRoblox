local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("InvData")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryEvents",1)
local AccessoryListModule = require(game.ServerScriptService:WaitForChild("AccessoryList"))
local AccessoryList = AccessoryListModule.GetAccesory()
local addAccTable = remoteEvent.AddAccesoryTableEvent
local remoteFunctionEquip = remoteEvent:FindFirstChild("SendEquippedToServer")

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
    local savedInventoryClient  = Instance.new("Folder")
    savedInventoryClient.Name = "AcessoryInventory"
    savedInventoryClient.Parent = player
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
    wait(5)
    -- passes player and accessory table
    addAccTable:FireClient(player,AccessoryList)
    local savedInventory = {}
    
    local success, error = pcall(function()
        savedInventory = dataStore:GetAsync(player.UserId)
    end)
    
    if success then
        print("Data Retrieved")       
    else
        print("Error :" .. error)
    end 
    if not savedInventory then
        local success, error = pcall(function()
        dataStore:setAsync(player.UserID, {})
        end)
        if success then
            print("Data Table created")
        else
            print("Error :" .. error)
        end
    end
    -- set of changed events which updates changed Equipped Slot this is where the Server would display
    -- any Accessory Changes
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
    dataStore:SetAsync(player.UserId, DataToStore)

end)
-- updates the Players Equipped so equipped accessories shows up in the servers
local function EquipToPlayer(player, ToBeEquipped)
    local loadout = player.Equipped
    for key in pairs(loadout) do
    loadout[key].Value = ToBeEquipped[key]
    end
    print(loadout)
end

remoteFunctionEquip.OnServerInvoke = EquipToPlayer
