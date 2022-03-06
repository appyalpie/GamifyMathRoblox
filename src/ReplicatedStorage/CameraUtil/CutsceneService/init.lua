--[[

Tutorial & Documentation: devforum.roblox.com/t/718571

Version of this module: 1.2.0

Created by Vaschex

Usage of KIIS added by 0J3_0

]]

local module = {
	Settings = {
		AddCutscenesToQueue = false
	}
}

-------------------------------------------------

local queue = {}
local KIIS = require(script.KIIS)
local plr = game.Players.LocalPlayer
local zoomController = require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule").CameraModule.ZoomController)
local controls = require(plr.PlayerScripts.PlayerModule):GetControls()
local easingFunctions = require(script.EasingFunctions)
local runService = game:GetService("RunService")
local StarterGui = game.StarterGui
local camera = workspace.CurrentCamera
local clock = os.clock
local playing = false

module.char = nil
module.rootPart = nil

if not module.CharacterLoaded then
	module.CharacterLoaded = true
	
	local function characterAdded(character)
		module.char = character
		module.rootPart = character:WaitForChild("HumanoidRootPart")
	end
	characterAdded(plr.Character or plr.CharacterAdded:Wait())
	plr.CharacterAdded:Connect(characterAdded)
end


local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.new()
	local self = setmetatable({}, Signal)

	self._argData = nil
	self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

	self._KIISBindable = KIIS.new()

	return self
end

function Signal:Fire(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._KIISBindable:Fire()
	self._argData = nil
	self._argCount = nil
end

function Signal:Connect(handler)
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end

	return self._KIISBindable:Connect(function()
		handler(unpack(self._argData, 1, self._argCount))
	end)
end

function Signal:Wait()
	-- Because KIIS does not support using :Wait(), we use a "Vanilla" bindableevent here.
	if not self._bindableEvent then
		self._bindableEvent = Instance.new("BindableEvent")

		self._KIISBindable:Connect(function() --when KIISBindable fires, the vanilla one fires
			if self._bindableEvent then
				self._bindableEvent:Fire()
			end
		end)
	end
	self._bindableEvent.Event:Wait()
	assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
	return unpack(self._argData, 1, self._argCount)
end

function Signal:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
	end;

	if self._KIISBindable and not self._KIISBindable.Destroyed then
		self._KIISBindable:Destroy()
	end;

	self._argData = nil
	self._argCount = nil
end

local function getPoints(folder) --returns point cframes in order
	folder = folder:GetChildren()
	local points = {}

	table.sort(folder, function(a,b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	for _,v in pairs(folder) do
		table.insert(points, v.CFrame)
	end

	return points
end

--This function is taken from a script by DejaVu_Loop and was optimized in Luau
type CFrameArray = { [number] : CFrame }
local function getCF(pointsTB: CFrameArray, ratio: number) : CFrame
	repeat
		local ntb : CFrameArray = {}
		for k, v in ipairs(pointsTB) do
			if k ~= 1 then
				ntb[k-1] = pointsTB[k-1]:Lerp(v, ratio)
			end
		end
		pointsTB = ntb
	until #pointsTB == 1
	return pointsTB[1]
end

local function getCoreGuisEnabled()
	return {
		Backpack = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack),
		Chat = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat),
		EmotesMenu = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu),
		Health = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health),
		PlayerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
	}
end

module.Functions = {
	DisableControls = "DisableControls",
	StartFromCurrentCamera = "StartFromCurrentCamera",
	EndWithCurrentCamera = "EndWithCurrentCamera",
	EndWithDefaultCamera = "EndWithDefaultCamera",
	YieldAfterCutscene = "YieldAfterCutscene",
	FreezeCharacter = "FreezeCharacter",
	CustomCamera = "CustomCamera",
}

function module:Create(pointsTemplate, duration, ...)
	assert(pointsTemplate, "Argument 1 (points) missing or nil")
	assert(duration, "Argument 2 (duration) missing or nil")
	local cutscene = {}
	local args = {...}
	local pausedPassedTime = 0 --stores progress of cutscene when paused
	local passedTime, start, previousCameraType, customCameraEnabled, points, previousCoreGuis

	cutscene.Completed = Signal.new()
	cutscene.PlaybackState = Enum.PlaybackState.Begin
	cutscene.Progress = 0

	if typeof(pointsTemplate) == "Instance" then
		assert(typeof(pointsTemplate) ~= "table", "Argument 1 (points) not an instance or table")
		pointsTemplate = getPoints(pointsTemplate)
	end

	local specialFunctionsTable = {
		Start = { --this is an array so you can iterate in order
			{"CustomCamera", function(customCamera)
				assert(customCamera, "CustomCamera Argument 1 missing or nil")
				camera = customCamera
				customCameraEnabled = true
			end},
			{"DisableControls", function()
				controls:Disable()
			end},
			{"FreezeCharacter", function(stopAnimations)
				if stopAnimations ~= false then
					for _, v in pairs(module.char.Humanoid.Animator:GetPlayingAnimationTracks()) do
						v:Stop()
					end
				end
				module.rootPart.Anchored = true
			end},
			{"StartFromCurrentCamera", function()
				table.insert(points, 1, camera.CFrame)
			end},
			{"EndWithCurrentCamera", function()				
				table.insert(points, camera.CFrame)
			end},
			{"EndWithDefaultCamera", function(useCurrentZoomDistance)
				local zoomDistance = 12.5
				if useCurrentZoomDistance == false then
					--pls help me: https://devforum.roblox.com/t/1209043
					--set camera zoomDistance to default for smooth transition when changing type to custom
					
					--zoomController.SetZoomParameters(zoomDistance, 0) isn't good
					
					local oldMin = plr.CameraMinZoomDistance
					local oldMax = plr.CameraMaxZoomDistance
					plr.CameraMaxZoomDistance = zoomDistance
					plr.CameraMinZoomDistance = zoomDistance
					wait()
					plr.CameraMaxZoomDistance = oldMax
					plr.CameraMinZoomDistance = oldMin
				else				
					zoomDistance = zoomController.GetZoomRadius()
					--zoomDistance = (camera.CFrame.Position - camera.Focus.Position).Magnitude
					--this is only the zoomDistance when there are no parts in the cameras way
				end
				local cameraOffset = CFrame.new(0, zoomDistance/2.6397830596715992, zoomDistance/1.0352760971197642)
				--Vector3.new(0, 4.7352376, 12.0740738)
				local lookAt = module.rootPart.CFrame.Position + Vector3.new(0, module.rootPart.Size.Y/2 + 0.5, 0)
				local at = (module.rootPart.CFrame * cameraOffset).Position

				table.insert(points,  CFrame.lookAt(at, lookAt))
			end},
		},
		End = {
			{"YieldAfterCutscene", function(waitTime)
				assert(waitTime, "YieldAfterCutscene Argument 1 missing or nil")
				wait(waitTime)
			end},
			{"DisableControls", function()
				controls:Enable(true)
			end},
			{"FreezeCharacter", function()
				module.rootPart.Anchored = false
			end},
			{"CustomCamera", function()
				camera.CameraType = previousCameraType
				camera = workspace.CurrentCamera
			end},
		}
	}

	local easingFunction = easingFunctions.Linear
	local dir, style = "In", nil
	for _, v in pairs(args) do
		if easingFunctions[v] then
			easingFunction = easingFunctions[v]
		elseif typeof(v) == "EnumItem" then
			if v.EnumType == Enum.EasingDirection then
				dir = v.Name
			elseif v.EnumType == Enum.EasingStyle then
				style = v.Name
			end
		end	
	end
	if style then
		assert(easingFunctions[dir..style], "EasingFunction "..dir..style.." not found")
		easingFunction = easingFunctions[dir..style]
	end

	local function checkNext(a, idx) --check if next argument is argument for special function
		local Next = args[idx+1]
		if (Next or Next == false) and typeof(Next) ~= "string" and typeof(Next) ~= "EnumItem" then
			table.insert(a, Next)
			checkNext(a, idx+1)
		end
	end

	local function callSpecialFunctions(Type)
		for i, v in ipairs(specialFunctionsTable[Type]) do
			local idx = table.find(args, v[1])
			if idx then
				local a = {} --arguments for special function
				checkNext(a, idx)
				if #a == 0 then
					v[2]()
				else
					v[2](unpack(a))
				end
			end
		end
	end

	function cutscene:Play()
		if playing == false then
			playing = true

			customCameraEnabled = false
			points = {unpack(pointsTemplate)}

			previousCoreGuis = getCoreGuisEnabled()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

			callSpecialFunctions("Start")

			assert(#points > 1, "More than one point is required")
			pausedPassedTime = 0
			cutscene.PlaybackState = Enum.PlaybackState.Playing
			previousCameraType = camera.CameraType
			camera.CameraType = Enum.CameraType.Scriptable
			start = clock()

			runService:BindToRenderStep("Cutscene", Enum.RenderPriority.Camera.Value, function()
				passedTime = clock() - start

				if passedTime <= duration then
					camera.CFrame = getCF(points, easingFunction(passedTime, 0, 1, duration))

					cutscene.Progress = passedTime / duration
				else
					runService:UnbindFromRenderStep("Cutscene")
					cutscene.Progress = 1

					callSpecialFunctions("End")

					playing = false
					cutscene.PlaybackState = Enum.PlaybackState.Completed
					cutscene.Completed:Fire(Enum.PlaybackState.Completed)
					if not customCameraEnabled then
						camera.CameraType = previousCameraType
					end

					if #queue > 0 then
						queue[1]:Play()
						table.remove(queue, 1)
					else
						for k, v in pairs(previousCoreGuis) do --reactive previous enabled coreguis
							if v then
								StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], true)
							end
						end
					end
				end
			end)

		else
			if module.Settings.AddCutscenesToQueue then			
				table.insert(queue, self)
			else
				warn("Error while calling :Play() - A cutscene was already playing")
			end
		end
	end

	function cutscene:Pause(waitTime)
		if playing then		
			runService:UnbindFromRenderStep("Cutscene")
			playing = false
			pausedPassedTime = passedTime
			cutscene.PlaybackState = Enum.PlaybackState.Paused

			if waitTime then
				wait(waitTime)
				self:Resume()
			end
		else
			warn("Error while calling :Pause() - There was no cutscene playing")
		end
	end

	function cutscene:Resume()
		if playing == false then
			if pausedPassedTime ~= 0 then
				playing = true

				cutscene.PlaybackState = Enum.PlaybackState.Playing
				camera.CameraType = Enum.CameraType.Scriptable
				start = clock() - pausedPassedTime

				runService:BindToRenderStep("Cutscene", Enum.RenderPriority.Camera.Value, function()
					passedTime = clock() - start

					if passedTime <= duration then
						camera.CFrame = getCF(points, easingFunction(passedTime, 0, 1, duration))

						cutscene.Progress = passedTime / duration
					else
						runService:UnbindFromRenderStep("Cutscene")
						cutscene.Progress = 1

						callSpecialFunctions("End")

						playing = false
						cutscene.PlaybackState = Enum.PlaybackState.Completed
						cutscene.Completed:Fire(Enum.PlaybackState.Completed)
						if not customCameraEnabled then
							camera.CameraType = previousCameraType
						end

						if #queue > 0 then
							queue[1]:Play()
							table.remove(queue, 1)
						else
							for k, v in pairs(previousCoreGuis) do --reactive previous enabled coreguis
								if v then
									StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[k], true)
								end
							end
						end			
					end
				end)

			else
				warn("Error while calling :Resume() - The cutscene isn't paused, use :Play() if you want to start it")
			end
		else
			warn("Error while calling :Resume() - The cutscene was already playing")
		end
	end

	function cutscene:Cancel()
		if playing then
			runService:UnbindFromRenderStep("Cutscene")
			playing = false
			camera.CameraType = previousCameraType
			cutscene.PlaybackState = Enum.PlaybackState.Cancelled
			cutscene.Completed:Fire(Enum.PlaybackState.Cancelled)
		else
			warn("Error while calling :Cancel() - There was no cutscene playing")
		end
	end

	return cutscene
end


return module
