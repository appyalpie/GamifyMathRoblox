local PaperObjects = {}
local TweenService = game:GetService("TweenService")

for _,v in pairs(game.Workspace.Island_3.Islands.PotionCreationTables:GetDescendants()) do
    if v.Name == "Paper" then
        table.insert(PaperObjects, v)
    end
end

local tweenInfo = TweenInfo.new(
    2,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    0,
    true,
    0
)

for _,v in pairs(PaperObjects) do
    local positionTween = TweenService:Create(v, tweenInfo, {Position = v.Position + Vector3.new(0, 0.3, 0)})
    local surfaceGuiPositionTween = TweenService:Create(v.SurfaceGuiPart, tweenInfo, {Position = v.SurfaceGuiPart.Position + Vector3.new(0, 0.3, 0)})

    wait(math.random(1,3) + math.random())

    positionTween:Play()
    surfaceGuiPositionTween:Play()
    positionTween.Completed:Connect(function()
        positionTween:Play()
    end)
    surfaceGuiPositionTween.Completed:Connect(function()
        surfaceGuiPositionTween:Play()
    end)

end


