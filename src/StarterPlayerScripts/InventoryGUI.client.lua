


local InvFunctions = require(script.parent:WaitForChild("Inventory"):WaitForChild("functions"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories"):WaitForChild("Template")

local AccesoryTable = require(game.ServerScriptService:WaitForChild("AccessoryList"))

local EquippedConnections = {}

-- this is suppose to add buttons to the list based on the AccessoryList contents
local function addToFrame(Accessory)
    local newtemplate = Acctemplate:Clone()
    newtemplate.Name = Accessory.Name
    newtemplate.AccessoryName.Text = Accessory.Name
    newtemplate.Parent = AccessoryList

    local newAccessory = Accessory:Clone()
    newAccessory.Parent = newtemplate.ViewportFrame

    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(newAccessory.PrimaryPart.Position + (newAccessory.PrimaryPart.CFrame.lookVector * 2),newAccessory.PrimaryPart.Position)
    camera.Parent = newtemplate.ViewportFrame

    newtemplate.ViewportFrame.CurrentCamera = camera

    EquippedConnections[#EquippedConnections + 1] = newtemplate.Activated:Connect(function()
        if newtemplate.Equipped[Accessory.Parent.Type] == nil then
            InvFunctions.functions.Equip(Accessory)
        else
            InvFunctions.functions.UnEquip(Accessory)
        end
    end)

end

--populates the Accesory Scrolling Frame with all the items 
local function Populate()
    for inst in pairs (AccesoryTable) do
        for inst2 in pairs (AccesoryTable.Type[inst]) do
            addToFrame(AccesoryTable.Type[inst2])
        end
    end
end

InventoryGUI:WaitForChild("HeadTest").Activated:Connect(function()
    
end)

Populate()





InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    print("this button works")
    InventoryGUI.Parent.Enabled = false
end)




