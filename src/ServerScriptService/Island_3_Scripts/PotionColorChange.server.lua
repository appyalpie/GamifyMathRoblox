local liquidsAndMore = {}
local TweenService = game:GetService("TweenService")

for _,v in pairs(game.Workspace.Island_3.Islands.PotionCreationTables:GetDescendants()) do
    if v.Name == "Liquid" then
        table.insert(liquidsAndMore, v)
    end
end

local tweenInfo = TweenInfo.new(
    5,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

for _,v in pairs(liquidsAndMore) do
    local yellowTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(1,1,0)})
    local greenTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(0,1,0)})
    local cyanTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(0,1,1)})
    local blueTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(0,0,1)})
    local magentaTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(1,0,1)})
    local redTween = TweenService:Create(v, tweenInfo, {Color = Color3.new(1,0,0)})
    wait(math.random(1,3) + math.random())

    yellowTween:Play()
    yellowTween.Completed:Connect(function()
        greenTween:Play()
    end)
    greenTween.Completed:Connect(function()
        cyanTween:Play()
    end)
    cyanTween.Completed:Connect(function()
        blueTween:Play()
    end)
    blueTween.Completed:Connect(function()
        magentaTween:Play()
    end)
    magentaTween.Completed:Connect(function()
        redTween:Play()
    end)
    redTween.Completed:Connect(function()
        yellowTween:Play()
    end)


end


