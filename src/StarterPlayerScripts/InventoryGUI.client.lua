local waiter = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Inventory"):WaitForChild("functions")
local InvFunctions = require(script.parent.Inventory.functions)

local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")
local template = script:WaitForChild("Template")

local AccesoryTable = require(game.ServerScriptService:WaitForChild("AccessoryList"))

local function addToFrame(Accessory)
    local newtemplate = template:Clone()
    newtemplate.Name = Accessory.Name
    newtemplate.AccessoryName.Text = Accessory.Name
    newtemplate.Parent = AccessoryList

    local newAccessory = Accessory:Clone()
    newAccessory.Parent = newtemplate.ViewportFrame

    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(newAccessory.PrimaryPart.Position + (newAccessory.PrimaryPart.CFrame.lookVector * 2),newAccessory.PrimaryPart.Position)
    camera.Parent = newtemplate.ViewportFrame

    newtemplate.ViewportFrame.CurrentCamera = camera
end

local function Populate()
    for inst in pairs (AccesoryTable) do
        for inst2 in pairs (AccesoryTable.Type[inst]) do
            addToFrame(AccesoryTable.Type[inst2])
        end
    end
end

Populate()





InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    print("this button works")
    InventoryGUI.Parent.Enabled = false
end)




