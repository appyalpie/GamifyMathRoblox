local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local QuestTrackerGui = PlayerGui:WaitForChild("QuestTrackerGui")
local OuterFrame = QuestTrackerGui:WaitForChild("OuterFrame")
local QuestListingFrame = OuterFrame:WaitForChild("QuestListingFrame")
local TemplateQuestFrame = QuestListingFrame:WaitForChild("TemplateQuestFrame")

local Button = OuterFrame:WaitForChild("Button")

------ Remote Events (Update and Handshake) ------
local QuestTrackerUpdateRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateRE")
local QuestTrackerUpdateReadyRE = ReplicatedStorage.RemoteEvents.QuestTrackerRE:WaitForChild("QuestTrackerUpdateReadyRE")

------ Wait for Update to Connect ------
QuestTrackerUpdateRE.OnClientEvent:Connect(function(questData)
    for _, v in pairs(QuestListingFrame:GetChildren()) do
        if v:GetAttribute("Index") ~= nil then
            v:Destroy()
        end
    end
    for _, v in pairs(questData) do
        if v.Status == "active" then
            local newQuestFrame = TemplateQuestFrame:Clone()
            newQuestFrame.Parent = QuestListingFrame
            newQuestFrame.Name = "QuestFrame"
            newQuestFrame:SetAttribute("Index", v.Index)

            local title = newQuestFrame.Title
            local description = newQuestFrame.Description
            if v.Amount ~= nil then
                title.Text = v.Title
                description.Text = " - " .. v.Description .. " [" .. v.Amount .. "/" .. v.AmountRequired .. "]"
            else
                title.Text = v.Title
                description.Text = v.Description
            end
            newQuestFrame.Visible = true
        end
    end
end)

------ Ready for the Update, Update time! ------
QuestTrackerUpdateReadyRE:FireServer()

local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isMoving = false

Button.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if OuterFrame:GetAttribute("isActive") == true and isMoving == false then
            local tween = TweenService:Create(OuterFrame, tweenInfo, {Position = UDim2.new(-0.125, 0, 0.22, 0)})
            tween:Play()
            isMoving = true
            local finishedTweenConnection
            finishedTweenConnection = tween.Completed:Connect(function()
                finishedTweenConnection:Disconnect()
                OuterFrame:SetAttribute("isActive", false)
                isMoving = false
            end)
        elseif OuterFrame:GetAttribute("isActive") == false and isMoving == false then
            local tween = TweenService:Create(OuterFrame, tweenInfo, {Position = UDim2.new(0.135, 0, 0.22, 0)})
            tween:Play()
            isMoving = true
            local finishedTweenConnection
            finishedTweenConnection = tween.Completed:Connect(function()
                finishedTweenConnection:Disconnect()
                OuterFrame:SetAttribute("isActive", true)
                isMoving = false
            end)
        end
    end
end)
