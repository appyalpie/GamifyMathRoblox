------ Services ------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

------ ModuleScripts / Objects ------
local GameUtilities = require(script:WaitForChild("GameUtilities"))
local GameInfo = require(script.Parent.GameInfo)
local CardList = require(script.CardList)
local CardObject = require(script.CardObject)
local Timer = require(ServerScriptService.Utilities:WaitForChild("Timer"))

------ Title Binding Remote Events ------
local PlayerSideShowNameAndTitleEvent = game.ReplicatedStorage:WaitForChild('PlayerSideShowNameAndTitleEvent')
local PlayerSideHideNameAndTitleEvent = game.ReplicatedStorage:WaitForChild('PlayerSideHideNameAndTitleEvent')
------ Movement Binding Remote Events ------
local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")
------ Camera Remote Events ------
local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")
------ Music Remote Event ------
local MusicEvent = game.ReplicatedStorage:WaitForChild("MusicEvent")

------ Models and Folders ------
local Level1_Card_Model = ServerStorage.Island_2.Game_24:WaitForChild("Level1_Card_Model")

local NPC_Challenger_Arenas = game.Workspace.Island_2.NPC_Challenger_Arenas
local Competitive_Arenas = game.Workspace.Island_2.Competitive_Arenas
local Competitive_Arenas_Manager = {{},{},{},{},{}} -- TODO: Change to dynamic?

local Game_24 = {}

local function Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
	if Game_Cards then
		-- clean up and destroy cards and operators if any
		for _, v in pairs(Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject:Destroy()
		end

		table.clear(Game_Cards)
		Game_Cards = nil -- allow cleanup
	end
	-- enable promptObject
	promptObject.Enabled = true

	-- reset currentGameInfo
	-- clean up folderAdded connection
	if CurrentGameInfo.cardFolderConnect then
		CurrentGameInfo.cardFolderConnect:Disconnect()
	end

	-- play the song that was playing before this
	MusicEvent:FireClient(player,"lastsound", 0.9)

	-- Show player name/title on player side
	PlayerSideShowNameAndTitleEvent:FireClient(player)

	-- Reenable Player Movement Controls
	UnlockMovementRE:FireClient(player)

	-- Reenable Player Camera Controls
	CameraSetFOVRE:FireClient(player, 70)
	CameraResetRE:FireClient(player)
end

function Game_24.initialize(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")

	-- Hide player name/title on player side
	PlayerSideHideNameAndTitleEvent:FireClient(player)

	-- play transition song (player, assetId, volume)
	MusicEvent:FireClient(player,"rbxassetid://9042916394", 0.45)

	-- Lock player movements
	LockMovementRE:FireClient(player)

	-- Disable proximityPrompt (one user at a time) and set user who is playing
	promptObject.Enabled = false

	-- Initialize game cards and connections
	local CurrentGameInfo = {}
	CurrentGameInfo.currentPlayer = player
	CurrentGameInfo.ancestorModel = ancestorModel
	CurrentGameInfo._winSequencePlaying = false
	CurrentGameInfo._orientation = math.rad(ancestorModel.PromptPart.Orientation.Y)
	CurrentGameInfo._orientationDegrees = ancestorModel.PromptPart.Orientation.Y
	CurrentGameInfo._defaultCameraCFrame = CFrame.new((Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.CameraXZOffset) + ancestorModel.PromptPart.Position + Vector3.new(0, GameInfo.CameraYOffset, 0)) * 
		CFrame.Angles(0, CurrentGameInfo._orientation + (math.pi / 2), 0) * -- Prevent Euler "Gimbal Lock"
		CFrame.Angles(-math.pi / 12, 0, 0)

    local Game_Cards = {}

	-- Lock and Move Player Camera to Position + Set FOV
	CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	CameraSetFOVRE:FireClient(player, GameInfo.FOV, GameInfo.FOVSetTime)

	-- Move player to position
	--player.Character:WaitForChild("HumanoidRootPart").Position = ancestorModel:GetAttribute("move_to_position") -- config
	player.Character:WaitForChild("HumanoidRootPart").Position = (Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.MOVE_POSITION_OFFSET) 
	+ ancestorModel.PromptPart.Position

	-- Tie cleanup events to death and leave
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		if CurrentGameInfo._winSequencePlaying == true then
			playerHumanoidDiedConnection:Disconnect()
			return
		end
		Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			if CurrentGameInfo._winSequencePlaying == true then
				playerLeaveConnection:Disconnect()
				return
			end
			Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
			playerLeaveConnection:Disconnect()
		end
	end)

	-- Pull a random question, category based on difficulty
	local difficulty = ancestorModel:GetAttribute("difficulty")
	CurrentGameInfo._difficulty = difficulty
	local cardPulled = CardList[difficulty][math.random(1, #CardList[difficulty])]

	-- Form to board
	local BoardCards = ancestorModel.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)

	-- Make cards reposition when a new card is added
	local CardFolder = ancestorModel.CardFolder
	CurrentGameInfo._cardFolder = CardFolder
	local gapSize = 4 --TODO: change to dynamic
	--local originalOriginPosition = ancestorModel:GetAttribute("origin_position") -- TODO: change to dynamic
	local originalOriginPosition = (Vector3.new(math.sin(CurrentGameInfo._orientation - (math.pi / 2)), 0, math.cos(CurrentGameInfo._orientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModel.PromptPart.Position - Vector3.new(0, 1.5, 0)

	CurrentGameInfo._originalOriginPosition = originalOriginPosition
	local cardAddedConnection
	CurrentGameInfo.cardFolderConnect = cardAddedConnection
	cardAddedConnection = CardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(originalOriginPosition, gapSize, iterator, #CardFolder:GetChildren(), CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		if #CardFolder:GetChildren() == 1 then -- check if winning condition is met
			for _, v in pairs(Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("YOU WIN!")
					cardAddedConnection:Disconnect()
					CurrentGameInfo._winSequencePlaying = true
					v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
					end)

					GameUtilities.Win_Sequence(Game_Cards, CurrentGameInfo, finishedWinSequenceEvent, player)
					return
				end
			end
		end
	end)
	
	--Spawn cards in TODO: animation and vfx, maybe some camera work
	local numberOfCards = 4
	for i = 1, numberOfCards do
		-- create a new card
		local newBaseCard = Level1_Card_Model:Clone()
		GameUtilities.Set_Orientation(newBaseCard.PrimaryPart, CurrentGameInfo._orientationDegrees)
		-- add card via card object to list of Game_Cards
		local newCardObject = CardObject.new()
		table.insert(Game_Cards, newCardObject)
		newCardObject._cardTable[2] = cardPulled[i]
		newCardObject._cardObject = newBaseCard
		newCardObject._startingPosition = newBaseCard.PrimaryPart.Position

		-- change parent
		newBaseCard.Parent = CardFolder

		-- adjust screen gui
		newCardObject:UpdateGUI()
	end
	
	
	-- Make cards selectable, via a function
	--print(Game_Cards)
	for _, v in pairs(Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModel, Game_Cards, CurrentGameInfo)
	end
end

local function CleanupTimed(promptObject, player, Game_Cards, CurrentGameInfo)
	------ Cleanup and Destroy Cards and Operators (if any) ------
	if Game_Cards then
		for _, v in pairs(Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject:Destroy()
		end

		table.clear(Game_Cards)
		Game_Cards = nil -- allow cleanup
	end
	------ Reset promptObject ------
	promptObject.Enabled = true
	------ Sanity Check for cardFolderConnect Cleanup ------
	if CurrentGameInfo.cardFolderConnect then
		CurrentGameInfo.cardFolderConnect:Disconnect()
	end
	------ Timer Reset ------
	CurrentGameInfo._timer = nil

	------ Cleanup Ring Constraints and Movers ------
	CurrentGameInfo.ancestorModel.HoldingPatternRings.Ring1.Center.Anchored = true
	for _, v in pairs(CurrentGameInfo.ancestorModel.HoldingPatternRings.Ring1.Center:GetChildren()) do
		if v:IsA("WeldConstraint") then
			v.Part1.Anchored = true
			v.Part0.Anchored = true
		end
		v:Destroy()
	end
	CurrentGameInfo.ancestorModel.HoldingPatternRings.Ring2.Center.Anchored = true
	for _, v in pairs(CurrentGameInfo.ancestorModel.HoldingPatternRings.Ring2.Center:GetChildren()) do
		if v:IsA("WeldConstraint") then
			v.Part1.Anchored = true
			v.Part0.Anchored = true
		end
		v:Destroy()
	end
	
	------ Reset Occupied Attribute ------
	for _, v in pairs(CurrentGameInfo.ancestorModel.HoldingPatternRings:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "Center" then
			v:SetAttribute("occupied", false)
		end
	end

	------ Reset Player Movement Controls ------
	UnlockMovementRE:FireClient(player)
	------ Reset Player Camera Controls ------
	CameraSetFOVRE:FireClient(player, 70)
	CameraResetRE:FireClient(player)
end

local function StartNextRound(player, ancestorModel, Game_Cards, CurrentGameInfo)
	------ Cleanup and Destroy Cards and Operators (if any) ------
	if Game_Cards then
		for i, v in pairs(Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject:Destroy()
			Game_Cards[i] = nil
		end
	end
	--Game_Cards = {}
	------ Lock and Move Player Camera to Position + Set FOV ------
	CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	CameraSetFOVRE:FireClient(player, GameInfo.FOV, GameInfo.FOVSetTime)
	------ Initialize a Random Card ------
	local difficulty = ancestorModel:GetAttribute("difficulty")
	CurrentGameInfo._difficulty = difficulty
	local cardPulled = CardList[difficulty][math.random(1, #CardList[difficulty])]
	------ Form New Card to Board ------
	local BoardCards = ancestorModel.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)
	------ Get Cards ------
	GameUtilities.Get_New_Cards(cardPulled, Game_Cards, CurrentGameInfo)
	------ Make Cards Selectable ------
	for _, v in pairs(Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModel, Game_Cards, CurrentGameInfo)
	end
end

local function initializeRingPatterns(ancestorModel, CurrentGameInfo)
	local Ring1 = ancestorModel.HoldingPatternRings.Ring1
	local Ring2 = ancestorModel.HoldingPatternRings.Ring2
	for _, v in pairs(Ring1:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "Center" then
			local weld = Instance.new("WeldConstraint")
			weld.Parent = Ring1.Center
			weld.Part0 = Ring1.Center
			weld.Part1 = v
			v.Anchored = false
			table.insert(CurrentGameInfo._ring1Slots, v) -- Each Slot Part also has an attribute "occupied"
		end
	end
	for _, v in pairs(Ring2:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "Center" then
			local weld = Instance.new("WeldConstraint")
			weld.Parent = Ring2.Center
			weld.Part0 = Ring2.Center
			weld.Part1 = v
			v.Anchored = false
			table.insert(CurrentGameInfo._ring2Slots, v)
		end
	end
	local bodyPosition1 = Instance.new("BodyPosition")
	bodyPosition1.Position = Ring1.Center.Position
	bodyPosition1.Parent = Ring1.Center
	local bodyPosition2 = Instance.new("BodyPosition")
	bodyPosition2.Position = Ring2.Center.Position
	bodyPosition2.Parent = Ring2.Center

	local bodyAngularVelocity1 = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity1.AngularVelocity = Vector3.new(.25,.31,.42)
	bodyAngularVelocity1.Parent = Ring1.Center
	local bodyAngularVelocity2 = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity2.AngularVelocity = Vector3.new(-.26,-.33,-.41)
	bodyAngularVelocity2.Parent = Ring2.Center

	Ring1.Center.Anchored = false
	Ring2.Center.Anchored = false
end

function Game_24.initializeTimed(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")

	------ Lock Player Movements ------
	LockMovementRE:FireClient(player)
	------ Disable proximityPrompt ------
	promptObject.Enabled = false
	------ Initialize CurrentGameInformation ------
	local CurrentGameInfo = {}
	CurrentGameInfo.currentPlayer = player
	CurrentGameInfo.ancestorModel = ancestorModel
	CurrentGameInfo._winSequencePlaying = false
	CurrentGameInfo._orientation = math.rad(ancestorModel.PromptPart.Orientation.Y)
	CurrentGameInfo._orientationDegrees = ancestorModel.PromptPart.Orientation.Y
	CurrentGameInfo._defaultCameraCFrame = CFrame.new((Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.CameraXZOffset) + ancestorModel.PromptPart.Position + Vector3.new(0, GameInfo.CameraYOffset, 0)) * 
		CFrame.Angles(0, CurrentGameInfo._orientation + (math.pi / 2), 0) * -- Prevent Euler "Gimbal Lock"
		CFrame.Angles(-math.pi / 12, 0, 0)

	CurrentGameInfo._foundSolutions = {}
	CurrentGameInfo._solutionDisplays = {}
	CurrentGameInfo._ring1Slots = {}
	CurrentGameInfo._ring2Slots = {}

	local Game_Cards = {}
	------ Initialize Timer ------
	local newTimer = Timer.new()
	newTimer.finished:Connect(function()
		GameUtilities.Timer_Finished_Single_Player(Game_Cards, CurrentGameInfo)
		CleanupTimed(promptObject, player, Game_Cards, CurrentGameInfo)
	end)
	CurrentGameInfo._timer = newTimer
	CurrentGameInfo._timerPart = ancestorModel.TimerPart
	------ Start Timer ------
	newTimer:start(GameInfo.SinglePlayerTimedDuration, CurrentGameInfo._timerPart)

	------ Lock and Move Player Camera to Position + Set FOV ------
	CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	CameraSetFOVRE:FireClient(player, GameInfo.FOV, GameInfo.FOVSetTime)
	------ Move player to position ------
	player.Character:WaitForChild("HumanoidRootPart").Position = (Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.MOVE_POSITION_OFFSET) + ancestorModel.PromptPart.Position
	------ Tie Cleanup to Death and Leave Event ------
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		if CurrentGameInfo._winSequencePlaying == true then -- If a win sequence is playing, then a cleanup will happen later
			playerHumanoidDiedConnection:Disconnect()
			return
		end
		CleanupTimed(promptObject, player, Game_Cards, CurrentGameInfo)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			if CurrentGameInfo._winSequencePlaying == true then
				playerLeaveConnection:Disconnect()
				return
			end
			CleanupTimed(promptObject, player, Game_Cards, CurrentGameInfo)
			playerLeaveConnection:Disconnect()
		end
	end)
	------ Initialize a Random Card ------
	local difficulty = ancestorModel:GetAttribute("difficulty")
	CurrentGameInfo._difficulty = difficulty
	local cardPulled = CardList[difficulty][math.random(1, #CardList[difficulty])]
	------ Form New Card to Board ------
	local BoardCards = ancestorModel.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)
	------ Card Reposition on Add to Folder ------
	local CardFolder = ancestorModel.CardFolder
	CurrentGameInfo._cardFolder = CardFolder
	local originalOriginPosition = (Vector3.new(math.sin(CurrentGameInfo._orientation - (math.pi / 2)), 0, math.cos(CurrentGameInfo._orientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModel.PromptPart.Position - Vector3.new(0, 1.5, 0)

	CurrentGameInfo._originalOriginPosition = originalOriginPosition
	local cardAddedConnection
	CurrentGameInfo.cardFolderConnect = cardAddedConnection
	cardAddedConnection = CardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(originalOriginPosition, GameInfo.GAP_SIZE, iterator, #CardFolder:GetChildren(), CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		------ 24 Success ------
		if #CardFolder:GetChildren() == 1 then --TODO: Move from children number to a more static and changeable number
			for _, v in pairs(Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("24 Card Created! No Other Cards Left")
					--cardAddedConnection:Disconnect()
					CurrentGameInfo._winSequencePlaying = true
					v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						if CurrentGameInfo._timer:isRunning() then
							print("Starting Next Round")
							CurrentGameInfo._winSequencePlaying = false
							StartNextRound(player, ancestorModel, Game_Cards, CurrentGameInfo)
						else
							return
						end
					end)

					GameUtilities.Win_Sequence_Timed_Single_Player(Game_Cards, CurrentGameInfo, finishedWinSequenceEvent)
					return
				end
			end
		end
	end)
	------ Get Cards ------
	GameUtilities.Get_New_Cards(cardPulled, Game_Cards, CurrentGameInfo)
	------ Make Cards Selectable ------
	for _, v in pairs(Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModel, Game_Cards, CurrentGameInfo)
	end
	------ Ring Initialization ------
	initializeRingPatterns(ancestorModel, CurrentGameInfo)
end

local function CleanupNPC(promptObject, player, Player_Game_Cards, NPC_Game_Cards, CurrentGameInfo)
	if Player_Game_Cards then
		for _, v in pairs(Player_Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject:Destroy()
		end
		table.clear(Player_Game_Cards)
		Player_Game_Cards = nil
	end

	if NPC_Game_Cards then
		for _, v in pairs(NPC_Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject:Destroy()
		end
		table.clear(NPC_Game_Cards)
		NPC_Game_Cards = nil
	end

	-- enable promptObject
	promptObject.Enabled = true

	-- move the opponent back
	CurrentGameInfo.currentOpponent.HumanoidRootPart.CFrame = CFrame.new(CurrentGameInfo._npcOldPosition) * CFrame.Angles(0, math.rad(CurrentGameInfo._npcOldOrientation.Y), 0)

	-- reset currentGameInfo
	-- clean up folderAdded connection
	if CurrentGameInfo.playerCardFolderConnect then
		CurrentGameInfo.playerCardFolderConnect:Disconnect()
	end
	if CurrentGameInfo.npcCardFolderConnect then
		CurrentGameInfo.npcCardFolderConnect:Disconnect()
	end

	-- play the song that was playing before this
	MusicEvent:FireClient(player,"lastsound", 0.9)

	-- give player controls back
	UnlockMovementRE:FireClient(player)

	-- Reenable Player Camera Controls
	CameraSetFOVRE:FireClient(player, 70)
	CameraResetRE:FireClient(player)

	
	-- Show player name/title on player side
	PlayerSideShowNameAndTitleEvent:FireClient(player)
end

function Game_24.initializeNPC(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model") -- got character
	local ancestorModelArena

	-- Hide player name/title on player side
	PlayerSideHideNameAndTitleEvent:FireClient(player)

	for _, v in pairs(NPC_Challenger_Arenas:GetChildren()) do
		--print("v: " .. v.Parent.Name)
		--print(ancestorModel.Name)
		--print(v:GetAttribute("challenger_arena_index"))
		--print(ancestorModel:GetAttribute("challenger_arena_index"))
		if v:GetAttribute("challenger_arena_index") == ancestorModel:GetAttribute("challenger_arena_index") then
			--print("Set")
			ancestorModelArena = v
		end
	end

	-- Lock player movements
	LockMovementRE:FireClient(player)

	-- Disable proximityPrompt (one user at a time) and set user who is playing
	promptObject.Enabled = false

	-- Initialize game cards and connections
	local CurrentGameInfo = {}
	CurrentGameInfo.currentPlayer = player
	CurrentGameInfo.currentOpponent = ancestorModel
	CurrentGameInfo._opponentName = ancestorModel.Name
	CurrentGameInfo.ancestorModel = ancestorModelArena
	CurrentGameInfo._winSequencePlaying = false
	CurrentGameInfo._orientation = math.rad(ancestorModelArena.PlayerTerminalPart.Orientation.Y)
	CurrentGameInfo._orientationDegrees = ancestorModelArena.PlayerTerminalPart.Orientation.Y
	CurrentGameInfo._playerOrientation = math.rad(ancestorModelArena.PlayerTerminalPart.Orientation.Y)
	CurrentGameInfo._playerOrientationDegrees = ancestorModelArena.PlayerTerminalPart.Orientation.Y

	CurrentGameInfo._npcOrientation = math.rad(ancestorModelArena.NPCTerminalPart.Orientation.Y)
	CurrentGameInfo._npcOrientationDegrees = ancestorModelArena.NPCTerminalPart.Orientation.Y

	CurrentGameInfo._defaultCameraCFrame = CFrame.new((Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.CameraXZOffset) + ancestorModelArena.PlayerTerminalPart.Position + Vector3.new(0, GameInfo.CameraYOffset, 0)) * 
		CFrame.Angles(0, CurrentGameInfo._orientation + (math.pi / 2), 0) * -- Prevent Euler "Gimbal Lock"
		CFrame.Angles(-math.pi / 12, 0, 0)

	-- Lock and Move Player Camera to Position + Set FOV
	CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	CameraSetFOVRE:FireClient(player, GameInfo.FOV, GameInfo.FOVSetTime)

	--check to see if we're fighing tommy
	if CurrentGameInfo.currentOpponent.Name == "Tommy Two Decks" then
		--play drum and bass
		MusicEvent:FireClient(player,"rbxassetid://9042934109", 0.9)
	else
		-- play transition song (player, assetId, volume)
		MusicEvent:FireClient(player,"rbxassetid://9042916394", 0.5)
	end

    local Game_Cards = {}
	local NPC_Game_Cards = {}

	-- Move player to position
	player.Character:WaitForChild("HumanoidRootPart").Position = (Vector3.new(math.sin(CurrentGameInfo._playerOrientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._playerOrientation + (math.pi / 2))) * GameInfo.MOVE_POSITION_OFFSET) 
		+ ancestorModelArena.PlayerTerminalPart.Position

	-- Save opponent position to move back to
	CurrentGameInfo._npcOldPosition = ancestorModel.HumanoidRootPart.Position
	CurrentGameInfo._npcOldOrientation = ancestorModel.HumanoidRootPart.Orientation

	-- Move opponent to position
	ancestorModel.HumanoidRootPart.CFrame = CFrame.new((Vector3.new(math.sin(CurrentGameInfo._npcOrientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._npcOrientation + (math.pi / 2))) * GameInfo.MOVE_POSITION_OFFSET) + ancestorModelArena.NPCTerminalPart.Position)
		* CFrame.Angles(0, math.rad(ancestorModelArena.NPCTerminalPart.Orientation.Y + 90), 0)

	-- Tie cleanup events to death and leave
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		if CurrentGameInfo._winSequencePlaying == true then
			playerHumanoidDiedConnection:Disconnect()
			return
		end
		CleanupNPC(promptObject, player, Game_Cards, NPC_Game_Cards, CurrentGameInfo)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			if CurrentGameInfo._winSequencePlaying == true then
				playerLeaveConnection:Disconnect()
				return
			end
			CleanupNPC(promptObject, player, Game_Cards, NPC_Game_Cards, CurrentGameInfo)
			playerLeaveConnection:Disconnect()
		end
	end)

	-- Pull a question based on difficulty
	local difficulty = ancestorModelArena:GetAttribute("difficulty")
	CurrentGameInfo._difficulty = difficulty
	local cardPulled = CardList[difficulty][math.random(1, #CardList[difficulty])]

	-- Form to board
	local BoardCards = ancestorModelArena.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)

	-- Make cards reposition when a new card is added
	local PlayerCardFolder = ancestorModelArena.CardFolder
	local AI_CardFolder = ancestorModelArena.AI_CardFolder
	CurrentGameInfo._cardFolder = PlayerCardFolder

	local gapSize = 4
	local originalOriginPosition = (Vector3.new(math.sin(CurrentGameInfo._playerOrientation - (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._playerOrientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModelArena.PlayerTerminalPart.Position - Vector3.new(0, 1.5, 0)

	CurrentGameInfo._originalOriginPosition = originalOriginPosition
	local playerCardAddedConnection
	CurrentGameInfo.playerCardFolderConnect = playerCardAddedConnection
	playerCardAddedConnection = PlayerCardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(originalOriginPosition, gapSize, iterator, #PlayerCardFolder:GetChildren(), CurrentGameInfo._playerOrientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		if #PlayerCardFolder:GetChildren() == 1 then
			for _, v in pairs(Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("YOU WIN!")
					playerCardAddedConnection:Disconnect()
					CurrentGameInfo._winSequencePlaying = true
					v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						CleanupNPC(promptObject, player, Game_Cards, NPC_Game_Cards, CurrentGameInfo)
					end)
					GameUtilities.Win_Sequence_Player(Game_Cards, NPC_Game_Cards, CurrentGameInfo, finishedWinSequenceEvent, player)
					return
				end
			end
		end
	end)

	local npcOriginalOriginPosition = (Vector3.new(math.sin(CurrentGameInfo._npcOrientation - (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._npcOrientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModelArena.NPCTerminalPart.Position - Vector3.new(0, 1.5, 0)

	CurrentGameInfo._npcOriginalOriginPosition = npcOriginalOriginPosition
	local npcCardAddedConnection
	CurrentGameInfo.npcCardFolderConnect = npcCardAddedConnection
	npcCardAddedConnection = AI_CardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(NPC_Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(npcOriginalOriginPosition, gapSize, iterator, #AI_CardFolder:GetChildren(), CurrentGameInfo._npcOrientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		if #AI_CardFolder:GetChildren() == 1 then
			for _, v in pairs(NPC_Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("YOU WIN!")
					npcCardAddedConnection:Disconnect()
					CurrentGameInfo._winSequencePlaying = true
					--v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						CleanupNPC(promptObject, player, Game_Cards, NPC_Game_Cards, CurrentGameInfo)
					end)
					GameUtilities.Win_Sequence_NPC(Game_Cards, NPC_Game_Cards, CurrentGameInfo, finishedWinSequenceEvent)
					return
				end
			end
		end
	end)
	
	--Spawn cards in TODO: animation and vfx, maybe some camera work
	local numberOfCards = 4
	for i = 1, numberOfCards do
		-- create a new card
		local newBaseCard = Level1_Card_Model:Clone()
		GameUtilities.Set_Orientation(newBaseCard.PrimaryPart, CurrentGameInfo._playerOrientationDegrees)
		-- add card via card object to list of Game_Cards
		local newCardObject = CardObject.new()
		table.insert(Game_Cards, newCardObject)
		newCardObject._cardTable[2] = cardPulled[i]
		newCardObject._cardObject = newBaseCard
		newCardObject._startingPosition = newBaseCard.PrimaryPart.Position

		-- change parent
		newBaseCard.Parent = PlayerCardFolder

		-- adjust screen gui
		newCardObject:UpdateGUI()
	end

	-- Create cards for NPC
	for i = 1, numberOfCards do
		local newBaseCard = Level1_Card_Model:Clone()
		GameUtilities.Set_Orientation(newBaseCard.PrimaryPart, CurrentGameInfo._npcOrientationDegrees)
		local newCardObject = CardObject.new()
		table.insert(NPC_Game_Cards, newCardObject)
		newCardObject._cardTable[2] = cardPulled[i]
		newCardObject._cardObject = newBaseCard
		newCardObject._startingPosition = newBaseCard.PrimaryPart.Position

		newBaseCard.Parent = AI_CardFolder

		newCardObject:UpdateGUI()
	end
	
	
	-- Make cards selectable, via a function
	for _, v in pairs(Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModelArena, Game_Cards, CurrentGameInfo)
	end

	GameUtilities.NPC_Action_Initialization(cardPulled[5], NPC_Game_Cards, CurrentGameInfo)
end

local function CleanupCompetitive(arena_index)
	------ Disconnect cardAdded to folder connection and reset movement and camera controls for both players ------
	for _, v in pairs(Competitive_Arenas_Manager[arena_index]) do
		---- Clean Up and Destroy Cards and Operators (if any) ----
		if v.Game_Cards then
			for _, c in pairs(v.Game_Cards) do
				GameUtilities.Hide_Operators(c)
				c._cardObject:Destroy()
			end
		end
		table.clear(v.Game_Cards)
		v.Game_Cards = nil

		if v.cardAddedConnection then
			v.cardAddedConnection:Disconnect()
		end

		if v.currentPlayer then
			---- Reset Movement ----
			UnlockMovementRE:FireClient(v.currentPlayer)

			---- Reset Player Camera Controls ----
			CameraSetFOVRE:FireClient(v.currentPlayer, 70)
			CameraResetRE:FireClient(v.currentPlayer)
		end
	end
	---- Reset promptObjects (2) ----
	for _, v in pairs(Competitive_Arenas_Manager[arena_index]) do
		if v.promptObject then
			v.promptObject.Enabled = true
		end
	end
	---- Remove Both Players From Table For That Arena ----
	table.clear(Competitive_Arenas_Manager[arena_index])
	Competitive_Arenas_Manager[arena_index] = {}
end

local function CleanupPreCompetitive(promptObject, player, CurrentGameInfo)
	table.remove(Competitive_Arenas_Manager[CurrentGameInfo._arena_index], table.find(Competitive_Arenas_Manager[CurrentGameInfo._arena_index], CurrentGameInfo)) -- remove player from that arena
	print(Competitive_Arenas_Manager)
	-- enable promptObject
	promptObject.Enabled = true

	-- Reenable Player Movement Controls
	UnlockMovementRE:FireClient(player)

	-- Reenable Player Camera Controls
	CameraSetFOVRE:FireClient(player, 70)
	CameraResetRE:FireClient(player)
end

function Game_24.preInitializationCompetitive(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model") -- Got Competitive_Arena
	local terminalPart = promptObject.Parent.Parent

	-- Disable proximityPrompt (one user at a time) and set user who is playing
	promptObject.Enabled = false

	local CurrentGameInfo = {}
	CurrentGameInfo.currentPlayer = player
	CurrentGameInfo.promptObject = promptObject
	CurrentGameInfo._terminalPart = terminalPart
	CurrentGameInfo._arena_index = ancestorModel:GetAttribute("arena_index")
	table.insert(Competitive_Arenas_Manager[CurrentGameInfo._arena_index], CurrentGameInfo)

	-- Tie cleanup events to death and leave
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		CleanupPreCompetitive(promptObject, player, CurrentGameInfo)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			CleanupPreCompetitive(promptObject, player, CurrentGameInfo)
			playerLeaveConnection:Disconnect()
		end
	end)

	CurrentGameInfo._playerHumanoidDiedConnection = playerHumanoidDiedConnection
	CurrentGameInfo._playerLeaveConnection = playerLeaveConnection

	-- Lock player movements
	LockMovementRE:FireClient(player)

	-- Initialize Some Game Information for the player
	CurrentGameInfo.ancestorModel = ancestorModel
	CurrentGameInfo._winSequencePlaying = false
	CurrentGameInfo._orientation = math.rad(terminalPart.Orientation.Y)
	CurrentGameInfo._orientationDegrees = terminalPart.Orientation.Y
	CurrentGameInfo._defaultCameraCFrame = CFrame.new((Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, 
		math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.CameraXZOffset) + terminalPart.Position + Vector3.new(0, GameInfo.CameraYOffset, 0)) * 
		CFrame.Angles(0, CurrentGameInfo._orientation + (math.pi / 2), 0) * -- Prevent Euler "Gimbal Lock"
		CFrame.Angles(-math.pi / 12, 0, 0)

	-- More Player specific information
	if terminalPart.Name == "Player1TerminalPart" then
		CurrentGameInfo._winSequenceFolder = CurrentGameInfo.ancestorModel.Player1WinSequenceFolder
	else
		CurrentGameInfo._winSequenceFolder = CurrentGameInfo.ancestorModel.Player2WinSequenceFolder
	end	
	
	-- Move player to position
	player.Character:WaitForChild("HumanoidRootPart").Position = (Vector3.new(math.sin(CurrentGameInfo._orientation + (math.pi / 2)), 0, math.cos(CurrentGameInfo._orientation + (math.pi / 2))) * GameInfo.MOVE_POSITION_OFFSET) 
	+ terminalPart.Position

	print(Competitive_Arenas_Manager)
	if #Competitive_Arenas_Manager[CurrentGameInfo._arena_index] == 2 then -- 2 players are in the arena detected
		Game_24.initializeCompetitive(CurrentGameInfo._arena_index)
	end
end

--[[
	Need information about all players that are currently queued
]]
function Game_24.initializeCompetitive(arena_index)
	print("Starting 24 Game Competititve Mode")
	------ Disconnect Old Death and Leave Cleanup and Initialize New ------
	for _, v in pairs(Competitive_Arenas_Manager[arena_index]) do
		v._playerHumanoidDiedConnection:Disconnect()
		v._playerHumanoidDiedConnection = v.currentPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
			CleanupCompetitive(arena_index)
			v._playerHumanoidDiedConnection:Disconnect()
		end)
		v._playerLeaveConnection:Disconnect()
		v._playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
			if removed == v.currentPlayer then
				CleanupPreCompetitive(arena_index)
				v._playerLeaveConnection:Disconnect()
			end
		end)
	end

	------ Move Camera for Both Players ------
	for _, v in pairs(Competitive_Arenas_Manager[arena_index]) do
		CameraMoveToRE:FireClient(v.currentPlayer, v._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
		CameraSetFOVRE:FireClient(v.currentPlayer, GameInfo.FOV, GameInfo.FOVSetTime)
	end

	-- TODO: Pull a random question, category based on difficulty
	------ defaulting to easy for now, later implement some sort of difficulty picking system ------
	local cardPulled = CardList["easy"][math.random(1, #CardList["easy"])]

	------ Some Variable Setup ------
	local ancestorModel = Competitive_Arenas_Manager[arena_index][1].ancestorModel
	local player1CurrentGameInfo
	local player2CurrentGameInfo
	if Competitive_Arenas_Manager[arena_index][1]._terminalPart.Name == "Player1TerminalPart" then
		player1CurrentGameInfo = Competitive_Arenas_Manager[arena_index][1]
		player2CurrentGameInfo = Competitive_Arenas_Manager[arena_index][2]
	else
		player1CurrentGameInfo = Competitive_Arenas_Manager[arena_index][2]
		player2CurrentGameInfo = Competitive_Arenas_Manager[arena_index][1]
	end
	local player1Game_Cards = {}
	local player2Game_Cards = {}
	player1CurrentGameInfo.Game_Cards = player1Game_Cards
	player2CurrentGameInfo.Game_Cards = player2Game_Cards

	------ Form Pulled Card to Board ------
	local BoardCards = ancestorModel.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)

	------ Player 1 Card Folder Connection ------
	player1CurrentGameInfo._cardFolder = ancestorModel.Player1CardFolder -- define to currentGameInfo -- Card Reposition when added to folder

	local player1OriginalOriginPosition = (Vector3.new(math.sin(player1CurrentGameInfo._orientation - (math.pi / 2)), 0, math.cos(player1CurrentGameInfo._orientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModel.Player1TerminalPart.Position - Vector3.new(0, 1.5, 0)
	player1CurrentGameInfo._originalOriginPosition = player1OriginalOriginPosition

	local player1CardAddedConnection
	player1CurrentGameInfo.cardFolderConnect = player1CurrentGameInfo._cardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(player1Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(player1OriginalOriginPosition, GameInfo.GAP_SIZE, iterator, 
			#player1CurrentGameInfo._cardFolder:GetChildren(), player1CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		if #player1CurrentGameInfo._cardFolder:GetChildren() == 1 then -- check if winning condition is met
			for _, v in pairs(player1Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("PLAYER 1 WINS!")
					player1CurrentGameInfo.cardFolderConnect:Disconnect()
					player2CurrentGameInfo.cardFolderConnect:Disconnect()
					player1CurrentGameInfo._winSequencePlaying = true
					player2CurrentGameInfo._winSequencePlaying = true
					v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						CleanupCompetitive(arena_index)
					end)

					GameUtilities.Win_Sequence_Competitive(player1CurrentGameInfo, player2CurrentGameInfo, player1Game_Cards, player2Game_Cards, finishedWinSequenceEvent)
					return
				end
			end
		end
	end)

	------ Player 2 Card Folder Connection ------
	player2CurrentGameInfo._cardFolder = ancestorModel.Player2CardFolder

	local player2OriginalOriginPosition = (Vector3.new(math.sin(player2CurrentGameInfo._orientation - (math.pi / 2)), 0, math.cos(player2CurrentGameInfo._orientation - (math.pi / 2))) * GameInfo.ORIGIN_POSITION_OFFSET) 
		+ ancestorModel.Player2TerminalPart.Position - Vector3.new(0, 1.5, 0)
	player2CurrentGameInfo._originalOriginPosition = player2OriginalOriginPosition

	local player2CardAddedConnection
	player2CurrentGameInfo.cardFolderConnect = player2CurrentGameInfo._cardFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(player2Game_Cards) do
			v._startingPosition = GameUtilities.Get_Starting_Position(player2OriginalOriginPosition, GameInfo.GAP_SIZE, iterator, 
			#player2CurrentGameInfo._cardFolder:GetChildren(), player2CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.PositionTweenInfo, {Position = v._startingPosition })
			positionTween:Play()
			
			iterator = iterator + 1
		end
		if #player2CurrentGameInfo._cardFolder:GetChildren() == 1 then -- check if winning condition is met
			for _, v in pairs(player2Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("PLAYER 2 WINS!")
					player1CurrentGameInfo.cardFolderConnect:Disconnect()
					player2CurrentGameInfo.cardFolderConnect:Disconnect()
					player1CurrentGameInfo._winSequencePlaying = true
					player2CurrentGameInfo._winSequencePlaying = true
					v._cardObject.Base_Card.ClickDetector:Destroy()

					local finishedWinSequenceEvent = Instance.new("BindableEvent")
					finishedWinSequenceEvent.Event:Connect(function()
						CleanupCompetitive(arena_index)
					end)

					GameUtilities.Win_Sequence_Competitive(player2CurrentGameInfo, player1CurrentGameInfo, player2Game_Cards, player1Game_Cards, finishedWinSequenceEvent)
					return
				end
			end
		end
	end)

	------ Spawn Cards For Player 1 ------ TODO: animation and vfx, maybe some camera work
	GameUtilities.Get_New_Cards(cardPulled, player1Game_Cards, player1CurrentGameInfo)

	------ Spawn Cards For Player 2 ------
	GameUtilities.Get_New_Cards(cardPulled, player2Game_Cards, player2CurrentGameInfo)
	
	------ Make Cards Selectable ------
	for _, v in pairs(player1Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModel, player1Game_Cards, player1CurrentGameInfo)
	end

	for _, v in pairs(player2Game_Cards) do
		GameUtilities.Card_Functionality(v, ancestorModel, player2Game_Cards, player2CurrentGameInfo)
	end
end

return Game_24
