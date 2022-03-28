local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InventoryItemInformation = require(ReplicatedStorage:WaitForChild("InventoryItemInformation"))

local InventoryInformationRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryInformationRF")
local InventoryEquipRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryEquipRF")
local InventoryUnequipRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryUnequipRF")

local InventoryGuiUtilities = {}

local Color3Lookup = {
    owned = Color3.fromRGB(133, 240, 138),
    equipped = Color3.fromRGB(0, 60, 255),
    inactive = Color3.fromRGB(140,140,140)
}

-- K: GUID V: 1.Button 2.ButtonConnection
local accessoryButtonGUIDTable = {}

-- 1: Button 2: Type ("owned" / "equipped" / "inactive")
local currentlySelected = {nil, nil}
local equipButtonConnection

InventoryGuiUtilities.CleanupEntry = function(GUID)
    if accessoryButtonGUIDTable[GUID][2] then
        accessoryButtonGUIDTable[GUID][2]:Disconnect()
    end
    if accessoryButtonGUIDTable[GUID][3] then
        accessoryButtonGUIDTable[GUID][3]:Disconnect()
    end
end

InventoryGuiUtilities.AddGUIDForButton = function(Button)
    local newGUID = HttpService:GenerateGUID(false)
    --table.insert(accessoryButtonGUIDTable, {newGUID, Button, nil, nil})
    accessoryButtonGUIDTable[newGUID] = {Button, nil, nil}
    Button:SetAttribute("GUID", newGUID)
end

------ Initialize GUIDs for all accessory buttons and save to attribute ------
InventoryGuiUtilities.InitializeAccessoryButtonIds = function(EquipsFrame)
    local ScrollingFrameBodyAccessories = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories")
    local ScrollingFrameHeadAccessories = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories")
    local ScrollingFrameLegAccessories = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
    ------ Body Accessories ------
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameBodyAccessories:WaitForChild("1"):WaitForChild("1"):WaitForChild("Button"))
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameBodyAccessories:WaitForChild("1"):WaitForChild("2"):WaitForChild("Button"))
    ------ Head Accessories ------
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameHeadAccessories:WaitForChild("1"):WaitForChild("1"):WaitForChild("Button"))
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameHeadAccessories:WaitForChild("1"):WaitForChild("2"):WaitForChild("Button"))
    ------ Leg Accessories ------
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameLegAccessories:WaitForChild("1"):WaitForChild("1"):WaitForChild("Button"))
    InventoryGuiUtilities.AddGUIDForButton(ScrollingFrameLegAccessories:WaitForChild("1"):WaitForChild("2"):WaitForChild("Button"))
end

------ Initializes All Inventory Items to be Unowned at the start ------
InventoryGuiUtilities.initializeInventoryMenu = function(InventoryMenu)
    print("Initializing Menu")
    for k, v in pairs(accessoryButtonGUIDTable) do
        InventoryGuiUtilities.CleanupEntry(k)
        print(k)
        v[2] = v[1].InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local DetailFrame = InventoryMenu.EquipsFrame:WaitForChild("DetailFrame")
                local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
                local TextFrame = DetailFrame:WaitForChild("TextFrame")
                local EquipButton = TextFrame:WaitForChild("EquipButton")
                local Description2 = TextFrame:WaitForChild("Description2")

                if equipButtonConnection and equipButtonConnection.Connected then
                    equipButtonConnection:Disconnect()
                end

                local inventoryInfo = InventoryItemInformation[v[1]:GetAttribute("item_name")]
                Description2.Text = inventoryInfo.Description
                currentlySelected = {v[1], "inactive"}
            end
        end)
    end
end

------ Unequip Accessories of a type (head, body, legs) ------
InventoryGuiUtilities.unequipAccessoriesOfType = function(player, type)
    local EquipmentFolder = player:FindFirstChild("EquipmentFolder")
    for _, v in pairs(EquipmentFolder:GetChildren()) do
        if InventoryItemInformation[v.Name].Type == type then
            v:Destroy()
        end
    end
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local EquippedAccessories = humanoid:GetAccessories()
    for _, v in pairs(EquippedAccessories) do
        if InventoryItemInformation[v.Name] then
            local typeOfAccessory = InventoryItemInformation[v.Name].Type
            if type == typeOfAccessory then
                v:Destroy()
            end
        end
    end
end

------ When a Player Clicks an Accessory which they have already Equipped ------
InventoryGuiUtilities.Click_Button_Equipped = function(input, itemButton, DetailFrame, playerItemInfo)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        print("Clicked on Button (Equipped)")
        local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
        local TextFrame = DetailFrame:WaitForChild("TextFrame")
        local EquipButton = TextFrame:WaitForChild("EquipButton")

        if equipButtonConnection then
            equipButtonConnection:Disconnect()
        end
        equipButtonConnection = EquipButton.InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                print("Got A click")
                local localPlayer = Players.LocalPlayer
                ------ Unequip Other Accessories of the same type (if any) ------
                -- InventoryGuiUtilities.unequipAccessoriesOfType(localPlayer, playerItemInfo.Type)
                ------ Unequip All Accessories of Type (Remove From Folder + Remove From Player) + Update GUI ------
                InventoryUnequipRF:InvokeServer(playerItemInfo.Type) 
                
                InventoryGuiUtilities.updateInventoryMenu(localPlayer, DetailFrame.Parent.Parent)
                InventoryGuiUtilities.Click_Button_Owned(input, itemButton, DetailFrame, playerItemInfo)
            end
        end)

        local Description2 = TextFrame:WaitForChild("Description2")
        Description2.Text = playerItemInfo.Description
        currentlySelected = {itemButton, "equipped"}
    end
end

InventoryGuiUtilities.Connect_Button_Equipped = function(itemButton, DetailFrame, playerItemInfo)
    local itemButtonConnection = itemButton.InputBegan:Connect(function(input, gameProcessed)
        InventoryGuiUtilities.Click_Button_Equipped(input, itemButton, DetailFrame, playerItemInfo)
    end)
    accessoryButtonGUIDTable[itemButton:GetAttribute("GUID")][2] = itemButtonConnection
end

------ When a Player Clicks an Accessory which they have own ------
InventoryGuiUtilities.Click_Button_Owned = function(input, itemButton, DetailFrame, playerItemInfo)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        print("Clicked on Button (Owned)")
        local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
        local TextFrame = DetailFrame:WaitForChild("TextFrame")
        local EquipButton = TextFrame:WaitForChild("EquipButton")

        if equipButtonConnection then
            equipButtonConnection:Disconnect()
        end
        equipButtonConnection = EquipButton.InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                print("Got A click")
                local localPlayer = Players.LocalPlayer
                ------ Unequip Other Accessories of the same type (if any) ------
                --InventoryGuiUtilities.unequipAccessoriesOfType(localPlayer, playerItemInfo.Type)
                InventoryUnequipRF:InvokeServer(playerItemInfo.Type)
                ------ Equip Accessory (Add To Folder + Add to Player) + Update GUI ------
                InventoryEquipRF:InvokeServer(itemButton)
                
                InventoryGuiUtilities.updateInventoryMenu(localPlayer, DetailFrame.Parent.Parent)
                InventoryGuiUtilities.Click_Button_Equipped(input, itemButton, DetailFrame, playerItemInfo)
            end
        end)

        local Description2 = TextFrame:WaitForChild("Description2")
        Description2.Text = playerItemInfo.Description
        currentlySelected = {itemButton, "owned"}
    end
end

InventoryGuiUtilities.Connect_Button_Owned = function(itemButton, DetailFrame, playerItemInfo)
    local itemButtonConnection = itemButton.InputBegan:Connect(function(input, gameProcessed)
        InventoryGuiUtilities.Click_Button_Owned(input, itemButton, DetailFrame, playerItemInfo)
    end)
    accessoryButtonGUIDTable[itemButton:GetAttribute("GUID")][2] = itemButtonConnection
end

------ Updates Equipped and Owned Accessory GUI, + Swaps Button Functionality based on Player Equipment and Ownership cached on Server ------
InventoryGuiUtilities.updateInventoryMenu = function(player, InventoryMenu)
    local EquipsFrame = InventoryMenu:WaitForChild("EquipsFrame")
    local typeToFrameDictionary = {
        ["body"] = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories"),
        ["head"] = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories"),
        ["leg"] = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
    }
    local playerInventoryData = InventoryInformationRF:InvokeServer() -- Table of all owned item names
    local playerEquipmentFolder -- Table of all equipped items
    if player:FindFirstChild("EquipmentFolder") then
        playerEquipmentFolder = player:FindFirstChild("EquipmentFolder")
    end

    for _, playerItemName in pairs(playerInventoryData) do
        ------ Get Info on Item ------
        local playerItemInfo = InventoryItemInformation[playerItemName]
        if playerItemInfo == nil then return end

        ------ Initialize Item Frames To Owned / Equipped------
        local typeFrame = typeToFrameDictionary[playerItemInfo.Type]
        local itemFrame = typeFrame:WaitForChild(playerItemInfo.Row):WaitForChild(playerItemInfo.Column)
        local itemButton = itemFrame:WaitForChild("Button")
        local DetailFrame = EquipsFrame:WaitForChild("DetailFrame")
        
        InventoryGuiUtilities.CleanupEntry(itemButton:GetAttribute("GUID"))

        if playerEquipmentFolder:FindFirstChild(playerItemName) then -- Item is equipped
            itemFrame.ImageColor3 = Color3Lookup.equipped
            InventoryGuiUtilities.Connect_Button_Equipped(itemButton, DetailFrame, playerItemInfo)
        else -- Item is not equipped
            itemFrame.ImageColor3 = Color3Lookup.owned
            InventoryGuiUtilities.Connect_Button_Owned(itemButton, DetailFrame, playerItemInfo)
        end
    end
end

return InventoryGuiUtilities