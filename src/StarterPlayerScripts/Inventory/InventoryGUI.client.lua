

local InvFunctions = require(script.parent.functions)

local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InventoryGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI.AFrame
local TitleList = InventoryGUI.TFrame
local BadgeList = InventoryGUI.ZFrame

InventoryGUI.CloseButton.Activated(function()
    InventoryGUI.Parent.Enabled = false
end)

--[[
    the method to add accessories will be as follows

AccessoryList.["Accesory Name Button"].Activated(function()
    InvFunctions.DisplayDescription(self.Item)
    InvFunctions.EquipItem(Player,self.Item)
    self.ImageColor3 = Color3.fromRGB(75, 255, 111)
end)
Similar button layouts can be used for TitleList and BadgeList


]]
