local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local VictoryEventRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("VictoryEventRE")
local DefeatEventRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("DefeatEventRE")

VictoryEventRE.OnClientEvent:Connect(function()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local VictoryDefeatGui = playerGui:WaitForChild("VictoryDefeatGui")
    local midbar = VictoryDefeatGui:WaitForChild("MidBar")
	local victorylabel = midbar:WaitForChild("VictoryLabel")
	local topaccent = midbar:WaitForChild("TopAccent"):WaitForChild("Frame"):WaitForChild("Accent")
	local botaccent = midbar:WaitForChild("BotAccent"):WaitForChild("Frame"):WaitForChild("Accent")

    local twinfo = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)
    topaccent.ImageColor3 = Color3.new(1, 1, 1)
    botaccent.ImageColor3 = Color3.new(1, 1, 1)

    local goal = {}
    goal.ImageTransparency = 0
    local tween1 = TweenService:Create(victorylabel,twinfo,goal)
    local tween2 = TweenService:Create(topaccent,twinfo,goal)
    local tween3 = TweenService:Create(botaccent,twinfo,goal)
    
    tween1:Play()
    tween2:Play()
    tween3:Play()
    
    wait(2)
    
    local goal2 = {}
    goal2.ImageTransparency = 1
    
    tween1 = TweenService:Create(victorylabel,twinfo,goal2)
    tween2 = TweenService:Create(topaccent,twinfo,goal2)
    tween3 = TweenService:Create(botaccent,twinfo,goal2)
    
    tween1:Play()
    tween2:Play()
    tween3:Play()
end)

DefeatEventRE.OnClientEvent:Connect(function()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local VictoryDefeatGui = playerGui:WaitForChild("VictoryDefeatGui")
    local midbar = VictoryDefeatGui:WaitForChild("MidBar")
	local defeatlabel = midbar:WaitForChild("DefeatLabel")
	local topaccent = midbar:WaitForChild("TopAccent"):WaitForChild("Frame"):WaitForChild("Accent")
	local botaccent = midbar:WaitForChild("BotAccent"):WaitForChild("Frame"):WaitForChild("Accent")

    local twinfo = TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)
    topaccent.ImageColor3 = Color3.fromRGB(255, 0, 0)
    botaccent.ImageColor3 = Color3.fromRGB(255, 0, 0)
    
    local goal = {}
    goal.ImageTransparency = 0
    local tween1 = TweenService:Create(defeatlabel,twinfo,goal)
    local tween2 = TweenService:Create(topaccent,twinfo,goal)
    local tween3 = TweenService:Create(botaccent,twinfo,goal)
    
    tween1:Play()
    tween2:Play()
    tween3:Play()
    
    wait(2)
    
    local goal2 = {}
    goal2.ImageTransparency = 1
    
    tween1 = TweenService:Create(defeatlabel,twinfo,goal2)
    tween2 = TweenService:Create(topaccent,twinfo,goal2)
    tween3 = TweenService:Create(botaccent,twinfo,goal2)
    
    tween1:Play()
    tween2:Play()
    tween3:Play()
end)