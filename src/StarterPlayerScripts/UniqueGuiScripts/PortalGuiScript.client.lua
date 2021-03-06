local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))

local QuestTrackerUpdateQuestRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateQuestRE")

local PortalGuiUpdateRE = ReplicatedStorage.RemoteEvents:WaitForChild("PortalGuiUpdateRE")
local PortalGuiUpdateIsland3BE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("BarrierAndPortalEvents"):WaitForChild("PortalGuiUpdateIsland3BE")
local PlayerPortalGuiLoadedRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("BarrierAndPortalEvents"):WaitForChild("PlayerPortalGuiLoadedRE")
local PlayerStatsRF = ReplicatedStorage:WaitForChild("PlayerStatsRF")
local localPlayer = Players.LocalPlayer

local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local UniqueOpenGui = PlayerGui:WaitForChild("UniqueOpenGui")
local MenuGui = UniqueOpenGui:WaitForChild("MenuGui")
local PortalMenu = MenuGui:WaitForChild("PortalMenu")
local InlayFrame1 = PortalMenu:WaitForChild("InlayFrame")
local InlayFrame2 = InlayFrame1:WaitForChild("InlayFrame")

-- extend to include other frames if more frames
local otherFrames = {MenuGui:WaitForChild("OptionsMenu"),MenuGui:WaitForChild("ShopMenu"),MenuGui:WaitForChild("InventoryMenu")}

local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local warpOffset = Vector3.new(0,5,0)

local function warpButton(input, gameProcessed, warpPosition)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(warpPosition + warpOffset)

        local tween = TweenService:Create(PortalMenu, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
    end
end

-- Connect buttons past warps 1 and 2 dependant on event being fired (fires on load and when a new area is unlocked)
-- Extendable to more parameters, (warp3Status, warp4Status, etc.)
PortalGuiUpdateRE.OnClientEvent:Connect(function(warp3Status)
    local WarpButton3 = InlayFrame2:WaitForChild("WarpButton3")
    local WarpTitle3 = InlayFrame2:WaitForChild("WarpTitle3")
    
    WarpButton3.BackgroundColor3 = Color3.fromRGB(255, 105, 105)
    WarpButton3.AutoButtonColor = true
    WarpTitle3.BackgroundColor3 = Color3.fromRGB(188, 188, 188)
    WarpTitle3.Text = "Alchemy"

    if warp3Status == true then
        WarpButton3.InputEnded:Connect(function(input, gameProcessed)
            warpButton(input, gameProcessed, WarpButton3:GetAttribute("warp_position"))
        end)
    end
end)

PortalGuiUpdateIsland3BE.Event:Connect(function(warp4Status)
    print("PortalGuiUpdateIsland3BE has been fired")
    local WarpButton4 = InlayFrame2:WaitForChild("WarpButton4")
    local WarpTitle4 = InlayFrame2:WaitForChild("WarpTitle4")
    
    WarpButton4.BackgroundColor3 = Color3.fromRGB(255, 105, 105)
    WarpButton4.AutoButtonColor = true
    WarpTitle4.BackgroundColor3 = Color3.fromRGB(188, 188, 188)

    if warp4Status == true then
        WarpButton4.InputEnded:Connect(function(input, gameProcessed)
            warpButton(input, gameProcessed, WarpButton4:GetAttribute("warp_position"))
        end)
    end
end)
PlayerPortalGuiLoadedRE:FireServer(Players.LocalPlayer)

-- Connect first two buttons (always present, when the player is at the main hub they can always goto 1 or 2)
local WarpButton1 = InlayFrame2:WaitForChild("WarpButton1")
WarpButton1.InputEnded:Connect(function(input, gameProcessed)
    warpButton(input, gameProcessed, WarpButton1:GetAttribute("warp_position"))
end)

local WarpButton2 = InlayFrame2:WaitForChild("WarpButton2")
WarpButton2.InputEnded:Connect(function(input, gameProcessed)
    warpButton(input, gameProcessed, WarpButton2:GetAttribute("warp_position"))
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        QuestTrackerUpdateQuestRE:FireServer(2, "active")
    end
end)

------ Exit Button ------
local ExitButton = PortalMenu:WaitForChild("ExitButton")
local function exit(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		script.Disabled = true
        local tween = TweenService:Create(PortalMenu, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
        local finishedTweenConnection
        finishedTweenConnection = tween.Completed:Connect(function()
            finishedTweenConnection:Disconnect()
            PortalMenu:SetAttribute("isActive",false)
            PortalMenu.Position = UDim2.new(0.5, 0, -0.5, 0)
            script.Disabled = false
        end)
	end
end
ExitButton.InputEnded:Connect(exit)

local MainHubPortal = game.Workspace.Main_Hub_Enclave.MainHubPortal.PortalPromptPart

local debounce = false
MainHubPortal.ProximityPrompt.Triggered:Connect(function(player)
    if debounce then return end
    debounce = true
    -- tween other frames out
    GuiUtilities.TweenOtherActiveFramesOut(otherFrames)

    -- set isActive
    PortalMenu:SetAttribute("isActive", true)

    local goal = {}
    goal.Position = UDim2.new(0.5,0,0.5,0)
    local tween = TweenService:Create(PortalMenu,tweenInfo2,goal)
    tween:Play() -- Tween the portal frame into view
    local finishedTweenConnection
    finishedTweenConnection = tween.Completed:Connect(function()
        finishedTweenConnection:Disconnect()
        debounce = false
    end)
end)

------ Get Player Data and set Player GUI when character is in ------
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local playerData = PlayerStatsRF:InvokeServer()

if playerData["BarrierToIsland3Down"] == true then
    local WarpButton3 = InlayFrame2:WaitForChild("WarpButton3")
    local WarpTitle3 = InlayFrame2:WaitForChild("WarpTitle3")

    WarpButton3.BackgroundColor3 = Color3.fromRGB(255, 105, 105)
    WarpButton3.AutoButtonColor = true
    WarpTitle3.BackgroundColor3 = Color3.fromRGB(188, 188, 188)
    WarpButton3.InputEnded:Connect(function(input, gameProcessed)
        warpButton(input, gameProcessed, WarpButton3:GetAttribute("warp_position"))
    end)
end