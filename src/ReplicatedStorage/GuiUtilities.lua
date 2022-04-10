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
--Accepts single Frames rather then table the next 2 functions
GuiUtilities.TweenCurrentFrameOut = function(CurrentFrame)
    if CurrentFrame:GetAttribute("isActive") == true then
    local tween = TweenService:Create(CurrentFrame, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
            tween:Play()
            local finishedTweenConnection
            finishedTweenConnection = tween.Completed:Connect(function()
                finishedTweenConnection:Disconnect()
                CurrentFrame:SetAttribute("isActive", false)
                CurrentFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
            end)
        end
end

GuiUtilities.TweenInCurrentFrame = function(CurrentFrame)
    print(CurrentFrame:GetAttribute("isActive"))
    if CurrentFrame:GetAttribute("isActive") == false then
        local tween = TweenService:Create(CurrentFrame, tweenInfo,{Position = UDim2.new(0.5, 0, 0.5, 0)})
        tween:Play()
        CurrentFrame:SetAttribute("isActive", true)
        
    end
end

--[[ Copied from ServerScriptService Utilities TODO: Refactor to only use this GUI utilities module ]]--
------ Bar starting from left and filling toward right ------
GuiUtilities.resizeCustomGuiLeftToRight = function(sizeRatio, clipping, top)
    clipping.Size = UDim2.new(sizeRatio, clipping.Size.X.Offset, clipping.Size.Y.Scale, clipping.Size.Y.Offset)
    top.Size = UDim2.new((sizeRatio > 0 and 1 / sizeRatio) or 0, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset)
end

return GuiUtilities