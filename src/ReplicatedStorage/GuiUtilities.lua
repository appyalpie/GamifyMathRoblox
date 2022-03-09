local TweenService = game:GetService("TweenService")

local GuiUtilities = {}

local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In)

GuiUtilities.TweenOtherActiveFramesOut = function(frames)
    for _, v in pairs(frames) do
        if v:GetAttribute("isActive") and v:GetAttribute("isActive") == true then
            local tween = TweenService:Create(v, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
            tween:Play()
            local finishedTweenConnection
            finishedTweenConnection = tween.Completed:Connect(function()
                finishedTweenConnection:Disconnect()
                v:SetAttribute("isActive", false)
                v.Position = UDim2.new(0.5, 0, -0.5, 0)
            end)
        end
    end
end

return GuiUtilities