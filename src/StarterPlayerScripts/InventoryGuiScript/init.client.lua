local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))
local InventoryGuiUtilities = require(script:WaitForChild("InventoryGuiUtilities"))

local localPlayer = Players.LocalPlayer

local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local UniqueOpenGui = PlayerGui:WaitForChild("UniqueOpenGui")
local MenuGui = UniqueOpenGui:WaitForChild("MenuGui")
local ButtonBar = MenuGui:WaitForChild("ButtonBar")
local InventoryMenu = MenuGui:WaitForChild("InventoryMenu")

-- extend to include other frames if more frames, [Used to tween other frames out when Inventory Frame comes in]
local targetFrame = InventoryMenu
local otherFrames = {MenuGui:WaitForChild("OptionsMenu"),MenuGui:WaitForChild("ShopMenu"),MenuGui:WaitForChild("PortalMenu")}

-- Tween Information --
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Color3 Changes for ButtonBars
local Color3Lookup = {
	active = Color3.fromRGB(232, 222, 113),
	inactive = Color3.fromRGB(195, 232, 179)
}

-- Input validity checker --
local checkValidInput = function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		return true
	else
		return false
	end
end

------ Initialize Accessory Buttons ------
local EquipsFrame = InventoryMenu:WaitForChild("EquipsFrame")
InventoryGuiUtilities.InitializeAccessoryButtonIds(EquipsFrame)
InventoryGuiUtilities.initializeInventoryMenu(InventoryMenu)

------ Exit Button ------
local ExitButton = InventoryMenu:WaitForChild("ExitButton")
local function exit(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		--script.Disabled = true
        local tween = TweenService:Create(InventoryMenu, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
        local finishedTweenConnection
        finishedTweenConnection = tween.Completed:Connect(function()
            finishedTweenConnection:Disconnect()
            InventoryMenu:SetAttribute("isActive",false)
            InventoryMenu.Position = UDim2.new(0.5, 0, -0.5, 0)
            --script.Disabled = false
        end)
	end
end
ExitButton.InputEnded:Connect(exit)

------ Enter Button ------
local InventoryButton = ButtonBar:WaitForChild("InventoryButton")
local function enter(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		------ If the inventory is already up, the button will now close it ------
		if targetFrame:GetAttribute("isActive") == true then
			exit(input, gameProcessed)
			return
		end
		--script.Disabled = true
		targetFrame:SetAttribute("isActive", true)

		------ Update Equips, Badges, and Titles ------
		InventoryGuiUtilities.updateInventoryMenu(localPlayer, InventoryMenu)

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
	end
end
InventoryButton.InputEnded:Connect(enter)

------ Equips Titles Badges [ButtonsBar] ------
local ButtonsBar = InventoryMenu:WaitForChild("ButtonsBar")
local BadgesButton = ButtonsBar:WaitForChild("Badges")
local EquipsButton = ButtonsBar:WaitForChild("Equips")
local TitlesButton = ButtonsBar:WaitForChild("Titles")
local function navigateTabs_ButtonsBar(targetButton, input)
	local buttonToFrameDictionary = {
		["Badges"] = InventoryMenu:WaitForChild("BadgesFrame"),
		["Equips"] = InventoryMenu:WaitForChild("EquipsFrame"),
		["Titles"] = InventoryMenu:WaitForChild("TitlesFrame")
	}
	for _, v in pairs(buttonToFrameDictionary) do
		v.Visible = false
	end
	buttonToFrameDictionary[targetButton.Name].Visible = true
end
BadgesButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_ButtonsBar(BadgesButton, input)
	BadgesButton.BackgroundColor3 = Color3Lookup.active
	EquipsButton.BackgroundColor3 = Color3Lookup.inactive
	TitlesButton.BackgroundColor3 = Color3Lookup.inactive
end)
EquipsButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_ButtonsBar(EquipsButton, input)
	BadgesButton.BackgroundColor3 = Color3Lookup.inactive
	EquipsButton.BackgroundColor3 = Color3Lookup.active
	TitlesButton.BackgroundColor3 = Color3Lookup.inactive
end)
TitlesButton.InputEnded:Connect(function(input)
	if not checkValidInput(input) then return end
	navigateTabs_ButtonsBar(TitlesButton, input)
	BadgesButton.BackgroundColor3 = Color3Lookup.inactive
	EquipsButton.BackgroundColor3 = Color3Lookup.inactive
	TitlesButton.BackgroundColor3 = Color3Lookup.active
end)

------ Head Body Legs [TypeButtonsBar] ------
local EquipsFrame =  InventoryMenu:WaitForChild("EquipsFrame")
local TypeButtonsBar = EquipsFrame:WaitForChild("TypeButtonsBar")
local HeadButton = TypeButtonsBar:WaitForChild("Head")
local BodyButton = TypeButtonsBar:WaitForChild("Body")
local LegsButton = TypeButtonsBar:WaitForChild("Legs")
local function navigateTabs_TypeButtonsBar(targetButton, input)
	local buttonToFrameDictionary = {
		["Body"] = EquipsFrame:WaitForChild("ScrollingFrameBodyAccessories"),
		["Head"] = EquipsFrame:WaitForChild("ScrollingFrameHeadAccessories"),
		["Legs"] = EquipsFrame:WaitForChild("ScrollingFrameLegAccessories")
	}
	for _, v in pairs(buttonToFrameDictionary) do
		v.Visible = false
		v.BackgroundColor3 = Color3Lookup.inactive
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