local waiter = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Inventory"):WaitForChild("functions")
wait(2)
local InvFunctions = require(script.parent.Inventory.functions)


local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")

InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    print("this button works")
    InventoryGUI.Parent.Enabled = false
end)

--[[
    Valid Types are
    ["Head"] = {},
    ["Legs"]  = {},
    ["Arms"] = {},
    ["Body"] = {}

    Descriptions are Sting variables attached to the button

    Item points to the Accessory model
]]

AccessoryList:WaitForChild("ImageButton1").Activated:Connect(function(self)
InvFunctions.DisplayDescription(self.Description)
InvFunctions.UnEquipItem(InvFunctions.get(), self.Type)
InvFunctions.EquipItem(Player,self.Item,self.Type)
self.ImageColor3 = Color3.fromRGB(75,255,111)
end)
AccessoryList:WaitForChild("ImageButton2").Activated:Connect(function(self)
    InvFunctions.DisplayDescription(self.Description)
    InvFunctions.UnEquipItem(InvFunctions.get(), self.Type)
    InvFunctions.EquipItem(Player,self.Item,self.Type)
    self.ImageColor3 = Color3.fromRGB(75,255,111)
    end)
AccessoryList:WaitForChild("ImageButton3").Activated:Connect(function(self)
    InvFunctions.DisplayDescription(self.Description)
    InvFunctions.UnEquipItem(InvFunctions.get(), self.Type)
    InvFunctions.EquipItem(Player,self.Item,self.Type)
    self.ImageColor3 = Color3.fromRGB(75,255,111)
    end)
--[[ Title button and Badge description would go here
TitleList:WaitForChild("TextButton").Activated:Connect(function(self)

end)
BadgeList:WaitForChild("TextButton").Activated:Connect(function(self)
InvFunctions.DisplayDescription()
end)
]]

--[[
    the method to add accessories will be as follows

AccessoryList.["Accesory Name Button"].Activated(function()
    InvFunctions.DisplayDescription(self.Item,self.Type)
    InvFunctions.EquipItem(Player,self.Item,self.Type)
    self.ImageColor3 = Color3.fromRGB(75, 255, 111)
end)
Similar button layouts can be used for TitleList and BadgeList


]]
