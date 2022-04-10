local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))
local ShopGuiUtilities = require(script:WaitForChild("ShopGuiUtilities"))

local ShopOpenBE = ReplicatedStorage.InventoryEventsNew:WaitForChild("ShopOpenBE")

local localPlayer = Players.LocalPlayer

local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local UniqueOpenGui = PlayerGui:WaitForChild("UniqueOpenGui")
local MenuGui = UniqueOpenGui:WaitForChild("MenuGui")
local ButtonBar = MenuGui:WaitForChild("ButtonBar")
local ShopMenu = MenuGui:WaitForChild("ShopMenu")

-- Color3 Changes for ButtonBars
local Color3Lookup = {
	active = Color3.fromRGB(232, 222, 113),
	inactive = Color3.fromRGB(195, 232, 179)
}

-- extend to include other frames if more frames, [Used to tween other frames out when Inventory Frame comes in]
local targetFrame = ShopMenu
local otherFrames = {MenuGui:WaitForChild("OptionsMenu"),MenuGui:WaitForChild("InventoryMenu"),MenuGui:WaitForChild("PortalMenu")}

-- Tween Information --
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Input validity checker --
local checkValidInput = function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		return true
	else
		return false
	end
end

ShopOpenBE.Event:Connect(function(Shopkeeper)
	------ Initialize Accessory Buttons (dynamically) ------
	local EquipsFrame = ShopMenu:WaitForChild("EquipsFrame")
	ShopGuiUtilities.InitializeAccessoryButtonIds(EquipsFrame, Shopkeeper)
	ShopGuiUtilities.hideAllShopItems(ShopMenu)
	ShopGuiUtilities.revealShopkeeperItems(Shopkeeper)
	ShopGuiUtilities.initializeShopMenu(ShopMenu, Shopkeeper)

	--script.Disabled = true
	targetFrame:SetAttribute("isActive", true)

	------ Update Shop Menu ------
	ShopGuiUtilities.updateShopMenu(localPlayer, ShopMenu, Shopkeeper)

	-- tween other frames out
	GuiUtilities.TweenOtherActiveFramesOut(otherFrames)
	
	local twinfo = TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0)
	local goal = {}
	goal.Position = UDim2.new(0.5,0,0.5,0)
	local tween1 = TweenService:Create(targetFrame,twinfo,goal)
	tween1:Play()
	tween1.Completed:Connect(function()
		--script.Disabled = false
	end)
end)

--[[
local Shopkeepers = game.Workspace.Shopkeepers
for _, v in pairs(Shopkeepers:GetChildren()) do
	v.HumanoidRootPart.ProximityPrompt.Triggered:Connect(function()
		------ Initialize Accessory Buttons (dynamically) ------
		local EquipsFrame = ShopMenu:WaitForChild("EquipsFrame")
		ShopGuiUtilities.InitializeAccessoryButtonIds(EquipsFrame, v.Name)
		ShopGuiUtilities.hideAllShopItems(ShopMenu)
		ShopGuiUtilities.revealShopkeeperItems(v.Name)
		ShopGuiUtilities.initializeShopMenu(ShopMenu, v.Name)

		--script.Disabled = true
		targetFrame:SetAttribute("isActive", true)

		------ Update Shop Menu ------
		ShopGuiUtilities.updateShopMenu(localPlayer, ShopMenu, v.Name)

		-- tween other frames out
		GuiUtilities.TweenOtherActiveFramesOut(otherFrames)
		
		local twinfo = TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0)
		local goal = {}
		goal.Position = UDim2.new(0.5,0,0.5,0)
		local tween1 = TweenService:Create(targetFrame,twinfo,goal)
		tween1:Play()
		tween1.Completed:Connect(function()
			--script.Disabled = false
		end)
	end)
end	
]]

------ Exit Button ------
local ExitButton = ShopMenu:WaitForChild("ExitButton")
local function exit(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		--script.Disabled = true
        local tween = TweenService:Create(ShopMenu, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
        local finishedTweenConnection
        finishedTweenConnection = tween.Completed:Connect(function()
            finishedTweenConnection:Disconnect()
            ShopMenu:SetAttribute("isActive",false)
            ShopMenu.Position = UDim2.new(0.5, 0, -0.5, 0)
            --script.Disabled = false
        end)
	end
end
ExitButton.InputEnded:Connect(exit)

------ Head Body Legs [TypeButtonsBar] ------
local EquipsFrame =  ShopMenu:WaitForChild("EquipsFrame")
local TypeButtonsBar = EquipsFrame:WaitForChild("TypeButtonsBar")
local HeadButton = TypeButtonsBar:WaitForChild("Head")
local BodyButton = TypeButtonsBar:WaitForChild("Body")
local LegsButton = TypeButtonsBar:WaitForChild("Legs")
local function navigateTabs_TypeButtonsBar(targetButton, input)
	if not checkValidInput(input) then return end
	local buttonToFrameDictionary = {
		["Body"] = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories"),
		["Head"] = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories"),
		["Legs"] = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
	}
	for _, v in pairs(buttonToFrameDictionary) do
		v.Visible = false
	end
	buttonToFrameDictionary[targetButton.Name].Visible = true
	buttonToFrameDictionary[targetButton.Name].BackgroundColor3 = Color3Lookup.active
end
HeadButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_TypeButtonsBar(HeadButton, input)
	HeadButton.BackgroundColor3 = Color3Lookup.active
	BodyButton.BackgroundColor3 = Color3Lookup.inactive
	LegsButton.BackgroundColor3 = Color3Lookup.inactive
end)
BodyButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_TypeButtonsBar(BodyButton, input)
	HeadButton.BackgroundColor3 = Color3Lookup.inactive
	BodyButton.BackgroundColor3 = Color3Lookup.active
	LegsButton.BackgroundColor3 = Color3Lookup.inactive
end)
LegsButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_TypeButtonsBar(LegsButton, input)
	HeadButton.BackgroundColor3 = Color3Lookup.inactive
	BodyButton.BackgroundColor3 = Color3Lookup.inactive
	LegsButton.BackgroundColor3 = Color3Lookup.active
end)