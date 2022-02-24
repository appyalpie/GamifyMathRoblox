
local InvFunctions = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Inventory"):WaitForChild("functions")


local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")
local CloseButton = InventoryGUI:FindFirstChild("CloseButton")

InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    print("this button works")
    InventoryGUI.Parent.Enabled = false
end)

AccessoryList:WaitForChild("ImageButton1").Activated:Connect(function()
print ("this button works")
end)

TitleList:WaitForChild("TextButton").Activated:Connect(function()
print("this button works")
end)
BadgeList:WaitForChild("TextButton").Activated:Connect(function()
print("this button works")
end)



--[[
    the method to add accessories will be as follows

AccessoryList.["Accesory Name Button"].Activated(function()
    InvFunctions.DisplayDescription(self.Item,self.Type)
    InvFunctions.EquipItem(Player,self.Item,self.Type)
    self.ImageColor3 = Color3.fromRGB(75, 255, 111)
end)
Similar button layouts can be used for TitleList and BadgeList


]]
