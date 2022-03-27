local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local TweenUtilities = {}

--[[
    Wrapper around normal tween functionality which allows multiply tweens of different style to be
    player on the same object.
]]
TweenUtilities.multiTweenFunction = function(tweenInfo, callback)
	local instance = Instance.new("Part") --Class name is arbitrary, just need an instance for TweenService to work with
	local property = "Transparency" --Property is also arbitrary, TweenService needs a property though
	local tween = TweenService:Create(instance, tweenInfo, {[property] = 1}) 
	
	local steppedC; steppedC = RunService.Stepped:Connect(function()
		callback(instance[property])
	end)
	
	tween:Play()
	
	local completedC; completedC = tween.Completed:Connect(function()
		if tween.PlaybackState == Enum.PlaybackState.Completed then
			callback(1)
		end
		
		steppedC:Disconnect()
		steppedC = nil
		completedC:Disconnect()
		completedC = nil
	end)
	
	return tween
end

function TweenUtilities.Fade(object, amount, time, delay)
	local tweenTransparency = TweenInfo.new(
		time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false,
		delay
	)
	local tween = TweenService:Create(object, tweenTransparency, {Transparency = amount})
	tween:Play()
end

------ UI Tween Utilities ------
function TweenUtilities.UITweenSize(object, size, time, delay)
	local tweenSizeInfo = TweenInfo.new(
		time,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out,
		0,
		false,
		delay
	)
	local tween = TweenService:Create(object, tweenSizeInfo, {Size = size})
	tween:Play()
end

function TweenUtilities.UITweenFadeText(object, transparency, time, delay)
	local tweenTextTransparency = TweenInfo.new(
		time,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false,
		delay
	)
	local tween = TweenService:Create(object, tweenTextTransparency, {TextTransparency = transparency})
	tween:Play()
end

function TweenUtilities.UITweenFadeBackground(object, transparency, time, delay)
	local tweenBackgroundTransparency = TweenInfo.new(
		time,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false,
		delay
	)
	local tween = TweenService:Create(object, tweenBackgroundTransparency, {BackgroundTransparency = transparency})
	tween:Play()
end

return TweenUtilities