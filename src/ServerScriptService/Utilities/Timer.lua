local MathUtilities = require(script.Parent:WaitForChild("MathUtilities"))

local Timer = {}
Timer.__index = Timer
 
function Timer.new()
	local self = setmetatable({}, Timer)
 
	self._finishedEvent = Instance.new("BindableEvent")
	self.finished = self._finishedEvent.Event
	
	self._running = false
	self._startTime = nil
	self._duration = nil
	
	return self
end
 
function Timer:start(duration, display)
	if not self._running then
		local timerThread = coroutine.wrap(function()
			self._running = true
			self._duration = duration
			self._startTime = tick()
			while self._running and tick() - self._startTime < duration do
				if display then
					for _, v in pairs(display:GetDescendants()) do
						if v:IsA("TextLabel") then
							v.Text = MathUtilities.formatTime(duration - (tick() - self._startTime))
						end
					end
				end
				wait()
			end
			local completed = self._running
			self._running = false
			self._startTime = nil
			self._duration = nil
			self._finishedEvent:Fire(completed)
			if display then
				for _, v in pairs(display:GetDescendants()) do
					if v:IsA("TextLabel") then
						v.Text = ""
					end
				end
			end
		end)
		timerThread()
	else
		warn("Warning: timer could not start again as it is already running.")
	end
end
 
function Timer:getTimeLeft()
	if self._running then
		local now = tick()
		local timeLeft = self._startTime + self._duration - now
		if timeLeft < 0 then
			timeLeft = 0
		end
		return timeLeft
	else
		warn("Warning: could not get remaining time, timer is not running.")
	end
end
 
function Timer:isRunning()
	return self._running
end
 
function Timer:stop()
	self._running = false
end
 
return Timer