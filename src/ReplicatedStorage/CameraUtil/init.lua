--// CameraUtil
--// Awesom3_Eric
--// June 2, 2021

--[[
		DOCUMENTATION

		-- Initialization -- 
		wait(1) 
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local CameraUtil = require(ReplicatedStorage.CameraUtil)
		local functions = CameraUtil.Functions
		local shakePresets = CameraUtil.ShakePresets

		local cameraInstance = workspace.CurrentCamera
		local camera = CameraUtil.Init(cameraInstance)
		
		
		-- Custom Functions --
		camera:MoveTo(target*, duration, style, direction) 						-- Moves camera to target
		camera:PointTo(target*, duration, style, direction) 					-- Faces camera towards target
		camera:Orbit(origin*, speed, horizontalOffset, verticalOffset, axes) 	-- Orbits camera around specific target
		camera:Rotate(origin*, speed, axis) 									-- Rotates camera on an axis	
		
		camera:Follow(part*) 													-- Camera consistently faces and follows target direction
		camera:Lock(part*) 														-- Camera attaches itself to a basepart
		camera:FocusOnPart(part*) 												-- Spectating a player, but for a part
		camera:FocusOnPlayer(player*) 											-- Acts like a spectate function
		
		camera:SetFOV(fov*, duration, style, direction)							-- Fade Camera FieldOfView
		
		camera:DisconnectAll() 													-- Cancels all cutscenes, updates, and tweens
		camera:Reset() 															-- Focuses camera back on player
		
		
		-- Derived Functions --
		camera:CreateCustcene(data*, duration*, style, direction, functions) -- Returns Cutscene Object
			cutsceneObject:Play()
			cutsceneObject:Pause(seconds)
			cutsceneObject:Resume()
			cutsceneObject:Cancel()
			cutsceneObject.Completed:Connect(function() end)
			
			SEE MORE INFO HERE: https://devforum.roblox.com/t/cutsceneservice-smooth-cutscenes-using-bezier-curves/718571/1
			
			
		camera:CreateShake() -- Returns shake object
			shakeObject:Start()
			shakeObject:Stop()
			shakeObject:Shake(shakePreset)
			shakeObject:ShakeSustain(shakePreset)
			shakeObject:StopSustained(fadeOutTime)
			shakeObject:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
			shakeObject:StartShake(magnitude, roughness, fadeInTime, posInfluence, rotInfluence)
			
			SEE MORE INFO HERE: https://devforum.roblox.com/t/ez-camera-shake-ported-to-roblox/98482
			OR GO TO CameraController > CameraShaker for example code, and CameraShaker > CameraShakePresets for shakePresets
]]--


local CameraUtil = {}
CameraUtil.__index = CameraUtil

--// Services and Variables \\--
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CutsceneService = require(script.CutsceneService)
local CameraShaker = require(script.CameraShaker)

-- References and defaults
CameraUtil.CameraCache = {}
CameraUtil.Functions = CutsceneService.Functions
CameraUtil.ShakePresets = CameraShaker.Presets
CameraUtil.DEFAULTS = {
	EASING_STYLE 		= Enum.EasingStyle.Quad,
	EASING_DIRECTION 	= Enum.EasingDirection.InOut,
	DURATION 			= 0
}



--// Local Functions \\--

--|| Returns target as CFrame from CFrame or BasePart ||--
local function getTarget(target)
	if not target then
		return nil
	end
	local targetType = typeof(target)
	if not (targetType == "Instance" or targetType == "CFrame") then
		return nil
	end
	return targetType == "Instance" and target.CFrame or target
end

--|| Returns Number of Seconds ||--
local function getDuration(duration)
	if not duration then
		return CameraUtil.DEFAULTS.DURATION
	end
	if typeof(duration) ~= "number" then
		return nil
	end
	return duration >= 0 and duration or duration * -1
end

--|| Returns EasingStyle or Default ||--
local function getEasingStyle(style)
	if not style then
		return CameraUtil.DEFAULTS.EASING_STYLE
	end
	local styleType = typeof(style)
	if not (styleType == "string" or styleType == "EnumItem") then
		return nil
	end
	return styleType == "string" and Enum.EasingStyle[style] or style
end

--|| Returns EasingDirection or Default ||--
local function getEasingDirection(direction)
	if not direction then
		return CameraUtil.DEFAULTS.EASING_DIRECTION
	end
	local directionType = typeof(direction)
	if not (directionType == "string" or directionType == "EnumItem") then
		return nil
	end
	return directionType == "string" and Enum.EasingDirection[direction] or direction
end



--// Functions \\--

--|| Initialize Camera ||--
function CameraUtil.Init(camera: CameraInstance)	
	-- Return existing camera
	if not CameraUtil.CameraCache[camera] then
		-- Check if camera is a Camera
		if not (camera and typeof(camera) == "Instance" and camera:IsA("Camera")) then
			warn("Camera not properly defined! Function CreateCamera(camera)")
			return
		end
		
		-- Create object
		local data = {
			Camera 				= camera,
			CurrentTween		= nil,
			CurrentRun			= nil,
			Cutscenes 			= {},
		}		
		function data.CancelRun()
			if data.CurrentRun then
				data.CurrentRun:Disconnect()
			end
		end
		
		function data.CancelTween()
			if data.CurrentTween then
				data.CurrentTween:Cancel()
			end
		end
			
		CameraUtil.CameraCache[camera] = data
		setmetatable(data, CameraUtil)
	end		
	
	return CameraUtil.CameraCache[camera]
end

--|| Tweens Camera CFrame to Target, Optional duration, style, and direction ||--
function CameraUtil:MoveTo(target: BasePartOrCFrame, duration: Number, style: EasingStyle, direction: EasingDirection)
	self:DisconnectAll()
	
	-- Check validity of arguments
	target 		= getTarget(target)
	duration 	= getDuration(duration)
	style 		= getEasingStyle(style)
	direction 	= getEasingDirection(direction)

	if not (target and duration and style and direction) then
		warn("Check Function :MoveTo(target, duration, style, direction). Formatting Invalid.")
		return
	end
	
	-- Set CFrame if duration is 0, or tween if greater
	if duration == 0 then
		self.Camera.CFrame = target
	else
		self.CurrentTween = TweenService:Create(
			self.Camera,
			TweenInfo.new(duration, style, direction),
			{CFrame = target}
		); self.CurrentTween:Play()
	end
end

--|| Tweens Camera to Point towards a Target, Optional duration, style, and direction ||--
function CameraUtil:PointTo(target: BasePartOrCFrame, duration: Number, style: EasingStyle, direction: EasingDirection)
	self:DisconnectAll()
	
	-- Check validity of arguments
	target 		= getTarget(target)
	duration 	= getDuration(duration)
	style 		= getEasingStyle(style)
	direction 	= getEasingDirection(direction)
	if not (target and duration and style and direction) then
		warn("Check Function :PointTo(target, duration, style, direction). Formatting Invalid.")
		return
	end
	
	-- Set CFrame if duration == 0 or tween if greater
	local origin = self.Camera.CFrame
	if duration == 0 then
		self.Camera.CFrame = CFrame.new(origin.Position, target.Position)
	else
		self.CurrentTween = TweenService:Create(
			self.Camera,
			TweenInfo.new(duration, style, direction),
			{CFrame = CFrame.new(origin.Position, target.Position)}
		); self.CurrentTween:Play()
	end
end

--|| Camera Follows Motion of BasePart ||--
function CameraUtil:Follow(part: BasePart)
	self:DisconnectAll()
	
	-- Check if target is an Instance
	if typeof(part) ~= "Instance" and not part:IsA("BasePart") then
		warn("Target must be instance. Function :Follow(target)")
		return
	end
	
	-- Update Camera CFrame in RenderStepped
	local origin = self.Camera.CFrame
	self.CurrentRun = RunService.RenderStepped:Connect(function()
		if not (part and part.Parent) then
			self.CurrentRun:Disconnect()
		end
		self.Camera.CFrame = CFrame.new(origin.Position, part.Position)
	end)
end

--|| Lock Camera to BasePart's CFrame ||--
function CameraUtil:Lock(part: BasePart)
	self.CancelRun()
	
	-- Check if target is an Instance
	if typeof(part) ~= "Instance" and not part:IsA("BasePart") then
		warn("Target must be instance. Function :Follow(target)")
		return
	end
	
	-- Update Camera CFrame in RenderStepped
	self.CurrentRun = RunService.RenderStepped:Connect(function()
		if not (part and part.Parent) then
			self.CurrentRun:Disconnect()
		end
		self.Camera.CFrame = part.CFrame
	end)
end

--|| Tween Camera POV ||--
function CameraUtil:SetFOV(fov: Number, duration: Number, style: EasingStyle, direction: EasingDirection)
	if self.FOVTween then
		self.FOVTween:Cancel()
	end
	
	-- Check validity of arguments
	duration 	= getDuration(duration)
	style 		= getEasingStyle(style)
	direction 	= getEasingDirection(direction)
	if not (duration and style and direction) then
		warn("Check Function :SetFOV(fov, duration, style, direction). Formatting Invalid.")
		return
	end
	if typeof(fov) ~= "number" then
		warn("FOV must be a number. Function :SetFOV(fov, duration, style, direction)")
		return
	end
	
	-- Set Camera FOV if duration is 0 or tween if greater
	if duration == 0 then
		self.Camera.FieldOfView = fov
	else
		self.FOVTween = TweenService:Create(
			self.Camera,
			TweenInfo.new(duration, style, direction),
			{FieldOfView = fov}
		); self.FOVTween:Play()
	end
end

--|| Sets Camera Subject to Player Humanoid ||--
function CameraUtil:FocusOnPlayer(player: Player)
	self:DisconnectAll()
	
	-- Check if player is valid
	self.Camera.CameraType = Enum.CameraType.Custom
	if not (player and typeof(player) == "Instance" and player:IsA("Player")) then
		self:Reset()
		return
	end
	
	if player == Player then
		self.Camera.CameraSubject = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("Humanoid")
	else
		-- Set CameraSubject every 0.1 second (to check if player left the game)
		local update = tick()
		self.CurrentRun = RunService.Heartbeat:Connect(function()
			if tick() - update > 0.1 then
				update = tick()
				-- If player left, return back to player
				if not (player and player.Parent) then
					self.CurrentRun:Disconnect()
					self:Reset()
					return
				end

				local character = player.Character
				if character and character:FindFirstChild("Humanoid") then
					self.Camera.CameraSubject = character.Humanoid
				end
			end
		end)
	end
end

--|| Set CameraSubject to Instance ||--
function CameraUtil:FocusOnPart(part: BasePart)
	self:DisconnectAll()
	
	-- Check if part is a BasePart
	if not (part and typeof(part) == "Instance" and part:IsA("BasePart")) then
		warn("Part must be a BasePart. Function :FocusOnPart(part).")
		return
	end
	
	-- Set CameraSubject
	self.Camera.CameraType = Enum.CameraType.Custom
	self.Camera.CameraSubject = part
end

--|| Rotate Camera on Axes, Optional speed, axes ||--
function CameraUtil:Rotate(origin: BasePartOrCFrame, speed: Number, ...: Table)
	self:DisconnectAll()
	
	-- Reestablish variables if invalid
	origin = getTarget(origin)
	origin = not origin and self.Camera.CFrame or origin
	speed = (speed and typeof(speed) == "number") and speed or 1

	-- Get angles of rotation
	local axes = {...}
	local angles = {}
	angles.X = (table.find(axes, "X") or table.find(axes, "x")) and math.pi/(1000/speed) or 0
	angles.Y = (table.find(axes, "Y") or table.find(axes, "y")) and math.pi/(1000/speed) or 0
	angles.Z = (table.find(axes, "Z") or table.find(axes, "z")) and math.pi/(1000/speed) or 0
	if angles == {} then
		angles = {Y = math.pi/(1000/speed)}
	end
	
	-- Rotate on RenderStepped
	local index = 1
	self.CurrentRun = RunService.RenderStepped:Connect(function()
		self.Camera.CFrame = origin * CFrame.Angles(angles.X * index, angles.Y * index, angles.Z * index)
		index += 1
	end)
end

--|| Orbit Around BasePart, Optional speed, horizontalOffset, verticalOffset ||--
function CameraUtil:Orbit(origin: BasePartOrCFrame, speed: Number, horizontalOffset: Number, verticalOffset: Number, ...: Table)
	self:DisconnectAll()
	
	-- Reestablish variables if invalid
	origin = getTarget(origin)
	origin = not origin and self.Camera.CFrame or origin	
	speed = (speed and typeof(speed) == "number") and speed or 1
	horizontalOffset = (horizontalOffset and typeof(horizontalOffset) == "number") and horizontalOffset or 0
	verticalOffset = (verticalOffset and typeof(verticalOffset) == "number") and verticalOffset or 0
	
	-- Get angles of rotation
	local axes = {...}
	local angles = {}
	angles.X = (table.find(axes, "X") or table.find(axes, "x")) and math.pi/(1000/speed) or 0
	angles.Y = (table.find(axes, "Y") or table.find(axes, "y")) and math.pi/(1000/speed) or 0
	angles.Z = (table.find(axes, "Z") or table.find(axes, "z")) and math.pi/(1000/speed) or 0
	if angles == {} then
		angles = {Y = math.pi/(1000/speed)}
	end
	
	-- Orbit around BasePart on 
	local index = 1
	local offset = CFrame.new(0, verticalOffset, -horizontalOffset)
	self.CurrentRun = RunService.RenderStepped:Connect(function()
		local rotation = CFrame.Angles(angles.X * index, angles.Y * index, angles.Z * index)
		self.Camera.CFrame = CFrame.new((origin * rotation * offset).Position, origin.Position)
		index += 1
	end)
end

--|| Cancel Tweens and RunService connections ||--
function CameraUtil:DisconnectAll()
	for _, cutscene in ipairs(self.Cutscenes) do
		cutscene.CutsceneObject:Cancel()
	end
	self.CancelRun()
	self.CancelTween()
	self.Camera.CameraType = Enum.CameraType.Scriptable; wait()
end

--|| Refocus Camera back on Player ||--
function CameraUtil:Reset()
	self:FocusOnPlayer(Player)
end



--// Derived Functions \\--
--|| Returns Shake Object ||--
function CameraUtil:CreateShake()
	if not self.Shaker then
		self.Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
			self.Camera.CFrame *= shakeCFrame
		end)
		self.Shaker:Start()
	end
	return self.Shaker
end

--|| Cutscene Class ||--
-- I had to make a new cutscene class so that when :Play() is called, I can call ":DisconnectAll()"
local Cutscene = {}
Cutscene.__index = Cutscene

function CameraUtil:CreateCutscene(...: Args)
	local data = {}
	local cutscene = CutsceneService:Create(...)
	data.CutsceneObject = cutscene
	data.Completed = cutscene.Completed
	
	setmetatable(data, Cutscene)
	table.insert(self.Cutscenes, data)
	return cutscene
end

function Cutscene:Play()
	CameraUtil.Camera:DisconnectAll()
	self.CutsceneObject:Play()
end
function Cutscene:Pause(...)
	self.CutsceneObject:Pause(...)
end
function Cutscene:Resume()
	self.CutsceneObject:Resume()
end
function Cutscene:Cancel()
	self.CutsceneObject:Cancel()
end



return CameraUtil