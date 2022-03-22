local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

------ ModuleScripts / Objects ------
local GameUtilities = require(script:WaitForChild("GameUtilities"))
local GameInfo = require(script.Parent.GameInfo)
local CardList = require(script.CardList)
local CardObject = require(script.CardObject)

------ Title Binding Remote Events ------
local PlayerSideShowNameAndTitleEvent = game.ReplicatedStorage.RemoteEvents.Titles:WaitForChild('PlayerSideShowNameAndTitleEvent')
local PlayerSideHideNameAndTitleEvent = game.ReplicatedStorage.RemoteEvents.Titles:WaitForChild('PlayerSideHideNameAndTitleEvent')
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

return Game_24
