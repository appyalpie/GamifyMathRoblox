


local InvFunctions = require(script.parent:WaitForChild("Inventory"):WaitForChild("functions"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories"):WaitForChild("Template")
local InventoryEvents = ReplicatedStorage:WaitForChild("RemoteEvents",5):WaitForChild("InventoryEvents",5)
local AccesoryTableEvent = InventoryEvents:WaitForChild("AddAccesoryTableEvent",1)
local GetPlayerSavedInventoryEvent = InventoryEvents:WaitForChild("InventoryStore",1)
local SendServerEquipped = InventoryEvents:WaitForChild("SendEquippedToServer",1)

local EquippedConnections = {}
AccesoryTable = {}

local function CheckForFire()
    local i =  0
    while not AccesoryTable do
        print(AccesoryTable)
        wait(1)
        i = i+1
        if i == 10 then
            return 0
        end
    end
    return true
end



-- this is suppose to add buttons to the list based on the AccessoryList contents
local function addToFrame(Accessory, Type)
    local newtemplate = Acctemplate:Clone()
    newtemplate.Name = Accessory.Name
    newtemplate.AccessoryName.Text = Accessory.Name
    newtemplate.Parent = AccessoryList

    local newAccessory = Accessory:Clone()
    newAccessory.Parent = newtemplate.ViewportFrame

    --local camera = Instance.new("Camera")
    --camera.CFrame = CFrame.new(newAccessory.PrimaryPart.Position + (newAccessory.PrimaryPart.CFrame.lookVector * 2),newAccessory.PrimaryPart.Position)
    --camera.Parent = newtemplate.ViewportFrame

    --newtemplate.ViewportFrame.CurrentCamera = camera

    local function GetAccessoryName()
        return Accessory.Name
    end

    EquippedConnections[#EquippedConnections + 1] = newtemplate.Activated:Connect(function()
        if not newtemplate.Equipped.Value then
            InvFunctions.Equip(Accessory,Type)
            newtemplate.Equipped.Value = true
        else
            InvFunctions.UnEquip(Type)
            newtemplate.Equipped.Value = false
        end
        print(InvFunctions["inventory"].Equipped)
        SendServerEquipped:InvokeServer(InvFunctions["inventory"].Equipped)
        
        return GetAccessoryName()
    end)

end

--populates the Accesory Scrolling Frame with all the items 
local function Populate(AccTable)
    
    if CheckForFire() then
        for key in pairs (AccTable) do
            for inst2 in pairs (AccTable[key]) do
                addToFrame(AccTable[key][inst2], key)
            end
        end
    end
end
--[[
    make sure when using AddItem that the Button Will be Disabled in the Shop GUI Note for Self 
    or other team member. 
]]
InventoryGUI:WaitForChild("HeadTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("HeadTest")
    InvFunctions.AddItem(Button)
    --a disable or hide button would go here
    InventoryGUI.HeadTest:Destroy()
end)
InventoryGUI:WaitForChild("BodyTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("BodyTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.BodyTest:Destroy()
end)
InventoryGUI:WaitForChild("LegTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("LegsTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.LegTest:Destroy()
end)
InventoryGUI:WaitForChild("ArmTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("ArmsTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.ArmTest:Destroy()
end)





InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    print("this button works")
    InventoryGUI.Parent.Enabled = false
end)

--fires Script on event passing player and AccessoryTable to target function
AccesoryTableEvent.OnClientEvent:Connect(Populate)


--stores saved inventory into InvFunctions table functions["InvData"]
GetPlayerSavedInventoryEvent.OnClientEvent:Connect(InvFunctions.store)
