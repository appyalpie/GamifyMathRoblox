local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UniqueOpenGui = PlayerGui:WaitForChild("UniqueOpenGui")
local MenuGui = UniqueOpenGui:WaitForChild("MenuGui")
local CheckpointsMenu = MenuGui:WaitForChild("CheckpointsMenu")
local CheckpointsFrame = CheckpointsMenu:WaitForChild("CheckpointsFrame")

local Bar = CheckpointsMenu:WaitForChild("Bar")
local CurrentCheckpoint = Bar:WaitForChild("CurrentCheckpoint")

local ExitButton = CheckpointsMenu:WaitForChild("ExitButton")

local ScrollingFrameCheckpoints = CheckpointsFrame:WaitForChild("ScrollingFrameCheckpoints")
local Row1 = ScrollingFrameCheckpoints:WaitForChild("1")
local Row2 = ScrollingFrameCheckpoints:WaitForChild("2")

local WarpButtonBar = CheckpointsFrame:WaitForChild("WarpButtonBar")
local Warp = WarpButtonBar:WaitForChild("Warp")
local SelectedCheckpoint = WarpButtonBar:WaitForChild("SelectedCheckpoint")

-- extend to include other frames if more frames
local otherFrames = {MenuGui:WaitForChild("OptionsMenu"),MenuGui:WaitForChild("ShopMenu"),MenuGui:WaitForChild("InventoryMenu"),MenuGui:WaitForChild("PortalMenu")}

local CheckpointSounds = SoundService:WaitForChild("CheckpointSounds")

local CheckpointTag = "Checkpoint"
local allCheckpoints = CollectionService:GetTagged(CheckpointTag)

local OpenCheckpointWarpGuiRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("OpenCheckpointWarpGuiRE")
local PlayCheckpointEffectsRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("PlayCheckpointEffectsRE")
local MovePlayerToCheckpointRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("MovePlayerToCheckpointRE")
local ClientReadyCheckpointRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ClientReadyCheckpointRE")
local SetCheckpointOnStartRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetCheckpointOnStartRE")

local CheckpointGhost = ReplicatedFirst:WaitForChild("CheckpointGhost")
local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))

local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local BrickColorLookup = {
	inactive = BrickColor.new("Medium red"),
	inactiveCenter = BrickColor.new("Bright red"),
	active = BrickColor.new("Sage green"),
	activeCenter = BrickColor.new("Lime green")
}

local PointLightColorLookup = {
	inactive = Color3.fromRGB(255, 0, 0),
	active = Color3.fromRGB(85, 255, 127)
}

local Color3Lookup = {
	red = Color3.fromRGB(255,0,0),
	green = Color3.fromRGB(0,170,0)
}

local RedColorSequence = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3Lookup.red),
	ColorSequenceKeypoint.new(1, Color3Lookup.red)
}

local GreenColorSequence = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3Lookup.green),
	ColorSequenceKeypoint.new(1, Color3Lookup.green)
}

local defaultSpinSpeed = .314
local fastSpinSpeed = 3.14

local checkpointButtonConnections = {}
local currentlySelectedCheckpoint = nil

PlayCheckpointEffectsRE.OnClientEvent:Connect(function(checkpointHit)
	------ Reset all other checkpoints to Red color ------
	for _, v in pairs(allCheckpoints) do
		local CheckpointDiamond = v.CheckpointDiamond
		CheckpointDiamond.BottomDiamond.BrickColor = BrickColorLookup.inactive
		CheckpointDiamond.TopDiamond.BrickColor = BrickColorLookup.inactive
		CheckpointDiamond.Center.BrickColor = BrickColorLookup.inactiveCenter
		CheckpointDiamond.Center.PointLight.Color = PointLightColorLookup.inactive
		v.Ambient.Fireflies.Color = RedColorSequence
	end
	
	------ Set newly hit checkpoint to green and play some sound ------
	-- Hit Checkpoint Effects (Ghost) --
	local checkpointGhost = CheckpointGhost:Clone()
	checkpointGhost.Parent = checkpointHit
	checkpointGhost.Position = checkpointHit.Checkpoint.Position
	-- Tween the checkpointGhost's ssize and transparency --
	local checkpointGhostTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local checkpointGhostTween = TweenService:Create(checkpointGhost, checkpointGhostTweenInfo, {Transparency = 1, 
		Size = Vector3.new(6,2,6)
	})
	checkpointGhostTween.Completed:Connect(function()
		checkpointGhost:Destroy()
	end)
	checkpointGhostTween:Play()
	
	------ Speedup and slow down ------
	local CheckpointDiamond = checkpointHit.CheckpointDiamond
	
	local Axle = CheckpointDiamond.Axle
	local MainMotor0 = Axle.MainMotor0
	local MainMotor1 = Axle.MainMotor1
	MainMotor0.AngularVelocity = fastSpinSpeed
	MainMotor1.AngularVelocity = fastSpinSpeed
	local motorSpeedTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local motor0SpeedTween = TweenService:Create(MainMotor0, motorSpeedTweenInfo, {AngularVelocity = defaultSpinSpeed})
	local motor1SpeedTween = TweenService:Create(MainMotor1, motorSpeedTweenInfo, {AngularVelocity = defaultSpinSpeed})
	motor0SpeedTween:Play()
	motor1SpeedTween:Play()
	
	------ Play Effects ------
	-- Explode --
	for _, v in pairs(CheckpointDiamond.Center.Explode_Particles:GetChildren()) do
		v.Enabled = true
	end
	local turnOffExplodeCoroutine = coroutine.wrap(function()
		wait(.75)
		for _, v in pairs(CheckpointDiamond.Center.Explode_Particles:GetChildren()) do
			v.Enabled = false
		end
	end)
	turnOffExplodeCoroutine()
	
	-- Swirl --
	CheckpointDiamond.Center.Particles.Swirl.Enabled = true
	local turnOffSwirlCoroutine = coroutine.wrap(function()
		wait(2)
		CheckpointDiamond.Center.Particles.Swirl.Enabled = false
	end)
	turnOffSwirlCoroutine()
	
	------ Change CheckpointDiamond Color ------
	CheckpointDiamond.BottomDiamond.BrickColor = BrickColorLookup.active
	CheckpointDiamond.TopDiamond.BrickColor = BrickColorLookup.active
	CheckpointDiamond.Center.BrickColor = BrickColorLookup.activeCenter
	CheckpointDiamond.Center.PointLight.Color = PointLightColorLookup.active
	checkpointHit.Ambient.Fireflies.Color = GreenColorSequence
	
	for _, v in pairs(CheckpointSounds:GetChildren()) do
		v:Play()
	end
end)

------ Exit Button ------
local function exit(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local tween = TweenService:Create(CheckpointsMenu, tweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
        local finishedTweenConnection
        finishedTweenConnection = tween.Completed:Connect(function()
            finishedTweenConnection:Disconnect()
            CheckpointsMenu:SetAttribute("isActive",false)
            CheckpointsMenu.Position = UDim2.new(0.5, 0, -0.5, 0)
        end)
	end
end
ExitButton.InputEnded:Connect(exit)

------ Open the Checkpoints GUI + Populate ------
local function findCheckpointButton(checkpoint)
	for _, v in pairs(Row1:GetChildren()) do
		if checkpoint == v:GetAttribute("checkpoint_num") then return v end
	end
	for _, v in pairs(Row2:GetChildren()) do
		if checkpoint == v:GetAttribute("checkpoint_num") then return v end
	end
end

Warp.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if currentlySelectedCheckpoint ~= nil then
			exit(input)
			MovePlayerToCheckpointRE:FireServer(currentlySelectedCheckpoint)
		end
	end
end)

local function addCheckpoint(checkpoint)
	local checkpointButton = findCheckpointButton(checkpoint)
	if checkpointButton == nil then return end

	if checkpoint == LocalPlayer:GetAttribute("current_checkpoint") then
		checkpointButton.Image = checkpointButton:GetAttribute("checkpoint_equipped")
	else
		checkpointButton.Image = checkpointButton:GetAttribute("checkpoint_active")
		local checkpointButtonConnection = checkpointButton.InputEnded:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				--- Change selected checkpoint and warp button
				SelectedCheckpoint.Text = checkpointButton:GetAttribute("checkpoint_name")
				print("CurrentlySelectedCheckpiont = " .. checkpoint)
				currentlySelectedCheckpoint = checkpoint
			end
		end)
		table.insert(checkpointButtonConnections, checkpointButtonConnection)
	end
end

local debounce = false
OpenCheckpointWarpGuiRE.OnClientEvent:Connect(function(prompt, checkpointData)
    if debounce then return end
    debounce = true
    -- tween other frames out
    GuiUtilities.TweenOtherActiveFramesOut(otherFrames)

    -- set isActive
    CheckpointsMenu:SetAttribute("isActive", true)

	-- DisconnectActiveButtons
	for _, v in pairs(checkpointButtonConnections) do
		v:Disconnect()
	end
	table.clear(checkpointButtonConnections)

	-- Populate
	for _, v in pairs(checkpointData) do
		addCheckpoint(v)
	end

	-- Change CurrentCheckpoint Title
	CurrentCheckpoint.Text = findCheckpointButton(prompt:FindFirstAncestorWhichIsA("Model"):GetAttribute("checkpoint_num")):GetAttribute("checkpoint_name")

	-- Reset current selection
	currentlySelectedCheckpoint = nil
	SelectedCheckpoint.Text = ""

    local goal = {}
    goal.Position = UDim2.new(0.5,0,0.5,0)
    local tween = TweenService:Create(CheckpointsMenu,tweenInfo2,goal)
    tween:Play() -- Tween the portal frame into view
    local finishedTweenConnection
    finishedTweenConnection = tween.Completed:Connect(function()
        finishedTweenConnection:Disconnect()
        debounce = false
    end)
end)

SetCheckpointOnStartRE.OnClientEvent:Connect(function(targetCheckpoint)
	for _, v in pairs(allCheckpoints) do
		if targetCheckpoint == v:GetAttribute("checkpoint_num") then
			------ Reset all other checkpoints to Red color ------
			for _, c in pairs(allCheckpoints) do
				local CheckpointDiamond = c.CheckpointDiamond
				CheckpointDiamond.BottomDiamond.BrickColor = BrickColorLookup.inactive
				CheckpointDiamond.TopDiamond.BrickColor = BrickColorLookup.inactive
				CheckpointDiamond.Center.BrickColor = BrickColorLookup.inactiveCenter
				CheckpointDiamond.Center.PointLight.Color = PointLightColorLookup.inactive
				c.Ambient.Fireflies.Color = RedColorSequence
			end
			------ Change CheckpointDiamond Color ------
			local CheckpointDiamond = v.CheckpointDiamond
			CheckpointDiamond.BottomDiamond.BrickColor = BrickColorLookup.active
			CheckpointDiamond.TopDiamond.BrickColor = BrickColorLookup.active
			CheckpointDiamond.Center.BrickColor = BrickColorLookup.activeCenter
			CheckpointDiamond.Center.PointLight.Color = PointLightColorLookup.active
			v.Ambient.Fireflies.Color = GreenColorSequence
			break
		end
	end
end)

ClientReadyCheckpointRE:FireServer()