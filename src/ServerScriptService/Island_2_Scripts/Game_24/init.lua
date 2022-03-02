local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local GameUtilities = require(script:WaitForChild("GameUtilities"))
local CardList = require(script.CardList)
local CardObject = require(script.CardObject)
local OperatorSetObject = require(script.OperatorSetObject)

local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")

local Operator_Set = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set")
local Base_Card = ServerStorage.Island_2.Game_24:WaitForChild("Base_Card")

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
	-- give player controls back
	UnlockMovementRE:FireClient(player)
end

function Game_24.initialize(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")

	-- Move player to position
	player.Character:WaitForChild("HumanoidRootPart").Position = ancestorModel:GetAttribute("move_to_position") -- config

	-- Lock player movements
	LockMovementRE:FireClient(player)

	-- Move player camera TODO:
	-- Lock player camera TODO:

	-- Disable proximityPrompt (one user at a time) and set user who is playing
	promptObject.Enabled = false

	-- Initialize game cards and connections
	local CurrentGameInfo = {}
	CurrentGameInfo.currentPlayer = player
    local Game_Cards = {}

	-- Tie cleanup events to death and leave
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
			playerLeaveConnection:Disconnect()
		end
	end)

	-- Pull a question -- TODO: work in difficulties
	local cardPulled = CardList[math.random(1, #CardList)]

	-- Form to board
	local BoardCards = ancestorModel.BoardCards
	GameUtilities.Board_Initialization(BoardCards, cardPulled)
	

	-- Make cards reposition when a new card is added
	local CardFolder = ancestorModel.CardFolder
	local gapSize = 4 --TODO: change to dynamic
	local originalOriginPosition = ancestorModel:GetAttribute("origin_position") -- TODO: change to dynamic
	local cardAddedConnection
	CurrentGameInfo.cardFolderConnect = cardAddedConnection
	cardAddedConnection = CardFolder.ChildAdded:Connect(function()
		local iterator = 0
		local origin = originalOriginPosition - (Vector3.new(0, 0, (.5)*(#CardFolder:GetChildren() - 1) * gapSize))
		--[[
		for i, v in ipairs(Game_Cards) do
			print("Index: " .. i)
			print(v)
		end
		]]
		for _, v in pairs(Game_Cards) do
			v._startingPosition = origin + Vector3.new(0, 0, iterator * gapSize)
			v._cardObject.Position = v._startingPosition
			iterator = iterator + 1
		end
		if #CardFolder:GetChildren() == 1 then -- check if winning condition is met
			for _, v in pairs(Game_Cards) do
				if v.calculateValue(v._cardTable) == 24 then
					print("YOU WIN!")
					cardAddedConnection:Disconnect()
					v._cardObject.ClickDetector:Destroy()
					wait(1) -- win sequence, split card back up into constituent parts! and showcase equation made
					Cleanup(promptObject, player, Game_Cards, CurrentGameInfo)
					return
				end
			end
		end
	end)
	
	--Spawn cards in TODO: animation and vfx, maybe some camera work
	local numberOfCards = 4
	for i = 1, numberOfCards do
		-- create a new card
		local newBaseCard = Base_Card:Clone()
		-- add card via card object to list of Game_Cards
		local newCardObject = CardObject.new()
		table.insert(Game_Cards, newCardObject)
		newCardObject._cardTable[2] = cardPulled[i]
		newCardObject._cardObject = newBaseCard
		newCardObject._startingPosition = newBaseCard.Position

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

return Game_24
