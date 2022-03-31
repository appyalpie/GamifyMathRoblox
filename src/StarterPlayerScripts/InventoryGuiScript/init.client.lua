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
	if not checkValidInput(input) then return end
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
	navigateTabs_ButtonsBar(BadgesButton, input)
end)
EquipsButton.InputEnded:Connect(function(input)
	navigateTabs_ButtonsBar(EquipsButton, input)
end)
TitlesButton.InputEnded:Connect(function(input)
	navigateTabs_ButtonsBar(TitlesButton, input)
end)

------ Head Body Legs [TypeButtonsBar] ------
local EquipsFrame =  InventoryMenu:WaitForChild("EquipsFrame")
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
end
HeadButton.InputEnded:Connect(function(input)
	navigateTabs_TypeButtonsBar(HeadButton, input)
end)
BodyButton.InputEnded:Connect(function(input)
	navigateTabs_TypeButtonsBar(BodyButton, input)
end)
LegsButton.InputEnded:Connect(function(input)
	navigateTabs_TypeButtonsBar(LegsButton, input)
end)