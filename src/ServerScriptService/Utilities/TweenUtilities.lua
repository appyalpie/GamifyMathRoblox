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

return TweenUtilities