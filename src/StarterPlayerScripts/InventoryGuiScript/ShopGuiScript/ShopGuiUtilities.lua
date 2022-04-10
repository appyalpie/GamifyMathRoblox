local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local ShopItemsInformation = require(ReplicatedStorage:WaitForChild("ShopItemsInformation"))

local PlayerStatsRF = ReplicatedStorage:WaitForChild("PlayerStatsRF")
local InventoryInformationRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("InventoryInformationRF")
local ShopPurchaseRF = ReplicatedStorage.InventoryEventsNew:WaitForChild("ShopPurchaseRF")

local InventoryViewportItems = ReplicatedFirst.InventoryViewportItems

local ShopGuiUtilities = {}

-- K: GUID V: 1.Button 2. BuyButtonConnection
local accessoryButtonGUIDTable = {}
local buyButtonConnection

local ViewportCameraOffset = CFrame.new(0, 0, 4)
local ViewportCameraSpeed = 20
local ViewportCameraRunServiceConnection

local Color3Lookup = {
    owned = Color3.fromRGB(133, 240, 138),
    inactive = Color3.fromRGB(140,140,140),
    buyButtonActive = Color3.fromRGB(52, 236, 39),
    buyButtonInactive = Color3.fromRGB(150,150,150)
}

local ShopkeeperToTitleLookup = {
    ["Llama"] = "Llama's Shinies",
    ["Skeleton At Tony V"] = "Bone's Goodies"
}

------_____ Shop Menu Stuff _____------

ShopGuiUtilities.CleanupEntry = function(GUID)
    if accessoryButtonGUIDTable[GUID][2] then
        accessoryButtonGUIDTable[GUID][2]:Disconnect()
    end
    if accessoryButtonGUIDTable[GUID][3] then
        accessoryButtonGUIDTable[GUID][3]:Disconnect()
    end
end

------ Used to create GUID and item_name attribute for buttons
ShopGuiUtilities.AddGUIDAndItemNameForButton = function(Button, itemName)
    local newGUID = HttpService:GenerateGUID(false)
    --table.insert(accessoryButtonGUIDTable, {newGUID, Button, nil, nil})
    accessoryButtonGUIDTable[newGUID] = {Button, nil, nil}
    Button:SetAttribute("GUID", newGUID)
    Button:SetAttribute("item_name", itemName)
end

------ Initialize GUIDs for all accessory buttons and save to attribute + Save item_name attribute ------
ShopGuiUtilities.InitializeAccessoryButtonIds = function(EquipsFrame, Shopkeeper)
    for k, _ in pairs(accessoryButtonGUIDTable) do
        ShopGuiUtilities.CleanupEntry(k)
    end
    table.clear(accessoryButtonGUIDTable)
    local ScrollingFrameBodyAccessories = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories")
    local ScrollingFrameHeadAccessories = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories")
    local ScrollingFrameLegAccessories = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
    local ShopkeeperInventoryInformation = ShopItemsInformation[Shopkeeper]
    for k, v in pairs(ShopkeeperInventoryInformation) do
        if v.Type == "body" then
            ShopGuiUtilities.AddGUIDAndItemNameForButton(ScrollingFrameBodyAccessories:WaitForChild(v.Row):WaitForChild(v.Column):WaitForChild("Button"), k)
        elseif v.Type == "head" then
            ShopGuiUtilities.AddGUIDAndItemNameForButton(ScrollingFrameHeadAccessories:WaitForChild(v.Row):WaitForChild(v.Column):WaitForChild("Button"), k)
        elseif v.Type == "leg" then
            ShopGuiUtilities.AddGUIDAndItemNameForButton(ScrollingFrameLegAccessories:WaitForChild(v.Row):WaitForChild(v.Column):WaitForChild("Button"), k)
        end
    end
end

ShopGuiUtilities.hideAllShopItems = function(ShopMenu)
    local EquipsFrame = ShopMenu.EquipsFrame
    local ScrollingFrameBodyAccessories = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories")
    local ScrollingFrameHeadAccessories = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories")
    local ScrollingFrameLegAccessories = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
    for _, v in pairs(ScrollingFrameBodyAccessories:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            v.Visible = false
        end
    end
    for _, v in pairs(ScrollingFrameHeadAccessories:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            v.Visible = false
        end
    end
    for _, v in pairs(ScrollingFrameLegAccessories:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            v.Visible = false
        end
    end
end

ShopGuiUtilities.revealShopkeeperItems = function(Shopkeeper)
    for _, v in pairs(accessoryButtonGUIDTable) do
        v[1].Parent.Visible = true
        v[1].Visible = true
        local shopItemInfo = ShopItemsInformation[Shopkeeper][v[1]:GetAttribute("item_name")]
        v[1].HoverImage = shopItemInfo.ImageAssetID
        v[1].Image = shopItemInfo.ImageAssetID
    end
end

ShopGuiUtilities.InitializeViewportCamera = function(PictureFrame)
    local ViewportFrame = PictureFrame:WaitForChild("ViewportFrame")
    local ViewportCamera
    if ViewportFrame:FindFirstChild("ViewportCamera") ~= nil then return end
    ViewportCamera = Instance.new("Camera")
    ViewportFrame.CurrentCamera = ViewportCamera
    ViewportCamera.Name = "ViewportCamera"
    ViewportCamera.Parent = ViewportFrame
    return ViewportCamera
end

------ Initialize all shop items to "not owned" (Item Frame + Button Connection) + Shopkeeper name update ------
ShopGuiUtilities.initializeShopMenu = function(ShopMenu, Shopkeeper)
    print("Initializing Shop")
    local Bar = ShopMenu:WaitForChild("Bar")
    local ShopTitle = Bar:WaitForChild("ShopTitle")
    local DetailFrame = ShopMenu.EquipsFrame:WaitForChild("DetailFrame")
    local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
    local TextFrame = DetailFrame:WaitForChild("TextFrame")
    local BuyButton = TextFrame:WaitForChild("BuyButton")
    local Description2 = TextFrame:WaitForChild("Description2") -- Description
    local Description4 = TextFrame:WaitForChild("Description4") -- Cost

    for k, v in pairs(accessoryButtonGUIDTable) do
        v[1].Parent.Visible = true
        v[1].Parent.ImageColor3 = Color3Lookup.inactive
        v[1].Visible = true
        ShopGuiUtilities.CleanupEntry(k) -- Cleanup Any Prior Button Connections
        v[2] = v[1].InputEnded:Connect(function(input, gameProcessed) -- Connect the Accessory Button (not the buy)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

                local shopItemInfo = ShopItemsInformation[Shopkeeper][v[1]:GetAttribute("item_name")]

                if buyButtonConnection and buyButtonConnection.Connected then
                    buyButtonConnection:Disconnect()
                end
                buyButtonConnection = BuyButton.InputEnded:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        print("Got A click")
                        local localPlayer = Players.LocalPlayer
                        ------ Send Request to Purchase the Accessory ------
                        ShopPurchaseRF:InvokeServer(Shopkeeper, v[1]:GetAttribute("item_name"))
                        
                        ShopGuiUtilities.updateShopMenu(localPlayer, DetailFrame.Parent.Parent, Shopkeeper)
                        ShopGuiUtilities.Click_Button_Owned(input, v[1], DetailFrame, shopItemInfo)
                    end
                end)
                local ViewportFrame = PictureFrame:WaitForChild("ViewportFrame")
                ------ Clear viewportFrame children and initialize new ------
                ViewportFrame:ClearAllChildren()
                local ViewportCamera = ShopGuiUtilities.InitializeViewportCamera(PictureFrame)
                local itemForViewport = InventoryViewportItems:WaitForChild(v[1]:GetAttribute("item_name")):Clone()
                itemForViewport.Parent = ViewportFrame
                ViewportCamera.CFrame = CFrame.new(ViewportCameraOffset.Position + itemForViewport.PrimaryPart.Position, itemForViewport.PrimaryPart.Position)
                local theta = 0
                local orientation = CFrame.new()
                local itemCFrame, itemSize = itemForViewport:GetBoundingBox()
                if ViewportCameraRunServiceConnection and ViewportCameraRunServiceConnection.Connected then
                    ViewportCameraRunServiceConnection:Disconnect()
                end
                ViewportCameraRunServiceConnection = RunService.RenderStepped:Connect(function(deltaTime)
                    theta = theta + math.rad(ViewportCameraSpeed * deltaTime)
                    orientation = CFrame.fromEulerAnglesYXZ(math.rad(-ViewportCameraSpeed), theta, 0)
                    ViewportCamera.CFrame = CFrame.new(itemCFrame.Position) * orientation * ViewportCameraOffset
                end)

                BuyButton.BackgroundColor3 = Color3Lookup.buyButtonActive
                Description2.Text = shopItemInfo.Description
                Description4.Text = shopItemInfo.Cost
            end
        end)

    end
    local ViewportFrame = PictureFrame:WaitForChild("ViewportFrame")
    ViewportFrame:ClearAllChildren()
    if buyButtonConnection and buyButtonConnection.Connected then
        buyButtonConnection:Disconnect()
    end
    ShopTitle.Text = ShopkeeperToTitleLookup[Shopkeeper]
    BuyButton.BackgroundColor3 = Color3Lookup.buyButtonInactive
    Description2.Text = ""
    Description4.Text = ""
end

ShopGuiUtilities.Click_Button_Owned = function(input, itemButton, DetailFrame, shopItemInfo)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        print("Clicked on Button (Owned)")
        local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
        local TextFrame = DetailFrame:WaitForChild("TextFrame")
        local BuyButton = TextFrame:WaitForChild("BuyButton")

        if buyButtonConnection then
            buyButtonConnection:Disconnect() -- If already owned, the buy button shall be disabled
        end

        local ViewportFrame = PictureFrame:WaitForChild("ViewportFrame")
        ------ Clear viewportFrame children and initialize new ------
        ViewportFrame:ClearAllChildren()
        local ViewportCamera = ShopGuiUtilities.InitializeViewportCamera(PictureFrame)
        local itemForViewport = InventoryViewportItems:WaitForChild(itemButton:GetAttribute("item_name")):Clone()
        itemForViewport.Parent = ViewportFrame
        ViewportCamera.CFrame = CFrame.new(ViewportCameraOffset.Position + itemForViewport.PrimaryPart.Position, itemForViewport.PrimaryPart.Position)
        local theta = 0
        local orientation = CFrame.new()
        local itemCFrame, itemSize = itemForViewport:GetBoundingBox()
        if ViewportCameraRunServiceConnection and ViewportCameraRunServiceConnection.Connected then
            ViewportCameraRunServiceConnection:Disconnect()
        end
        ViewportCameraRunServiceConnection = RunService.RenderStepped:Connect(function(deltaTime)
            theta = theta + math.rad(ViewportCameraSpeed * deltaTime)
            orientation = CFrame.fromEulerAnglesYXZ(math.rad(-ViewportCameraSpeed), theta, 0)
            ViewportCamera.CFrame = CFrame.new(itemCFrame.Position) * orientation * ViewportCameraOffset
        end)

        BuyButton.BackgroundColor3 = Color3Lookup.buyButtonInactive
        local Description2 = TextFrame:WaitForChild("Description2")
        Description2.Text = shopItemInfo.Description
        local Description4 = TextFrame:WaitForChild("Description4") -- Cost
        Description4.Text = shopItemInfo.Cost
    end
end

ShopGuiUtilities.Connect_Button_Owned = function(itemButton, DetailFrame, shopItemInfo)
    local itemButtonConnection = itemButton.InputBegan:Connect(function(input, gameProcessed)
        ShopGuiUtilities.Click_Button_Owned(input, itemButton, DetailFrame, shopItemInfo)
    end)
    accessoryButtonGUIDTable[itemButton:GetAttribute("GUID")][2] = itemButtonConnection
end

------ Updates Owned Accessories GUI + Swaps Button Functionality ------
ShopGuiUtilities.updateShopMenu = function(player, ShopMenu, Shopkeeper)
    local EquipsFrame = ShopMenu:WaitForChild("EquipsFrame")
    local typeToFrameDictionary = {
        ["body"] = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories"),
        ["head"] = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories"),
        ["leg"] = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
    }

    local playerData = PlayerStatsRF:InvokeServer(false) -- Player Data to get Currency
    local playerInventoryData = InventoryInformationRF:InvokeServer() -- Table of all owned item names
    
    --print(playerInventoryData)
    print(playerData)
    ------ Initialize Currency ------
    local PlayerCurrency = EquipsFrame:WaitForChild("PlayerCurrency")
    PlayerCurrency.Text = "Currency: " .. playerData["Currency"]
    
    for _, playerItemName in pairs(playerInventoryData) do
        ------ Get Info on Item ------
        local shopItemInfo = ShopItemsInformation[Shopkeeper][playerItemName]
        if shopItemInfo == nil then continue end
        --print(playerItemName)

        ------ Initialize Item Frames To Owned / Equipped------
        local typeFrame = typeToFrameDictionary[shopItemInfo.Type]
        local itemFrame = typeFrame:WaitForChild(shopItemInfo.Row):WaitForChild(shopItemInfo.Column)
        local itemButton = itemFrame:WaitForChild("Button")
        local DetailFrame = EquipsFrame:WaitForChild("DetailFrame")
        
        ShopGuiUtilities.CleanupEntry(itemButton:GetAttribute("GUID")) 

        itemFrame.ImageColor3 = Color3Lookup.owned
        ShopGuiUtilities.Connect_Button_Owned(itemButton, DetailFrame, shopItemInfo)
    end
end

return ShopGuiUtilities