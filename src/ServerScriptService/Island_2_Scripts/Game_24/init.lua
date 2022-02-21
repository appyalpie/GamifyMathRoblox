local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local GameUtilities = require(script.GameUtilities)
local CardList = require(script.CardList)
local CardObject = require(script.CardObject)
local OperatorSetObject = require(script.OperatorSetObject)

--local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovement")
--local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovement")

local Operator_Set = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set")
local Base_Card = ServerStorage.Island_2.Game_24:WaitForChild("Base_Card")

local Game_24 = {}

local function Reveal_Operators(newCard, model, Game_Cards)
	-- Create new operator set object
	local newOperatorSetObject = OperatorSetObject.new()
	-- clone operator set
	newOperatorSetObject._operatorSet = Operator_Set:Clone()
	-- set the card's operators to the new object
	newCard._operatorSetObject = newOperatorSetObject
	
	local operatorSet = newOperatorSetObject._operatorSet -- label for ease of access
	operatorSet.Parent = game.Workspace -- TODO: set to somewhere else
	local offset = Vector3.new(0,4,0)
	operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.Position + offset))
	newOperatorSetObject._cardPositionChangedSignal = newCard._cardObject:GetPropertyChangedSignal("Position"):Connect(function()
		operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.Position + offset))
	end)
	
	-- Make Operator Selectable
	newOperatorSetObject._addClickDetectorSignal = operatorSet.Add.ClickDetector.MouseClick:Connect(function()
		if newOperatorSetObject._operatorSelectedName ~= nil then -- something is selected
			if newOperatorSetObject._addOperatorSelected then -- specifically add is selected (deselect add)
				--print("Deselected Add")
				--operatorSelected = false
				newOperatorSetObject:DeselectAll()
			else -- add was not selected, but something is selected (select add, deselect other)
				--print("Deselected Something, Selected Add")
				--operatorSelected doesnt change
				newOperatorSetObject:DeselectAll()
				newOperatorSetObject:SelectSpecific("add")
			end
		else -- nothing is selected (select add)
			--print("Selected Add")
			--operatorSelected = true
			newOperatorSetObject:SelectSpecific("add")
		end
	end)
	newOperatorSetObject._subtractClickDetectorSignal = operatorSet.Subtract.ClickDetector.MouseClick:Connect(function()
		if newOperatorSetObject._operatorSelectedName ~= nil then
			if newOperatorSetObject._subtractOperatorSelected then
				newOperatorSetObject:DeselectAll()
			else
				newOperatorSetObject:DeselectAll()
				newOperatorSetObject:SelectSpecific("subtract")
			end
		else
			newOperatorSetObject:SelectSpecific("subtract")
		end
	end)
	newOperatorSetObject._multiplyClickDetectorSignal = operatorSet.Multiply.ClickDetector.MouseClick:Connect(function()
		if newOperatorSetObject._operatorSelectedName ~= nil then
			if newOperatorSetObject._multiplyOperatorSelected then
				newOperatorSetObject:DeselectAll()
			else
				newOperatorSetObject:DeselectAll()
				newOperatorSetObject:SelectSpecific("multiply")
			end
		else
			newOperatorSetObject:SelectSpecific("multiply")
		end
	end)
	newOperatorSetObject._divideClickDetectorSignal = operatorSet.Divide.ClickDetector.MouseClick:Connect(function()
		if newOperatorSetObject._operatorSelectedName ~= nil then
			if newOperatorSetObject._divideOperatorSelected then
				newOperatorSetObject:DeselectAll()
			else
				newOperatorSetObject:DeselectAll()
				newOperatorSetObject:SelectSpecific("divide")
			end
		else
			newOperatorSetObject:SelectSpecific("divide")
		end
	end)
	
	-- if the card selected is a combined card, then reveal undo button as well
	if type(newCard._cardTable[2]) == "table" then
		operatorSet.Undo.Transparency = 0
		newOperatorSetObject._undoClickDetectorSignal = operatorSet.Undo.ClickDetector.MouseClick:Connect(function()
			-- split card into two cards
			local splitCard1 = CardObject.new()
			splitCard1._cardTable = newCard._cardTable[2] -- reference
			splitCard1._cardObject = Base_Card:Clone()
			local splitCard2 = CardObject.new()
			splitCard2._cardTable = newCard._cardTable[3] -- reference
			splitCard2._cardObject = Base_Card:Clone()

			splitCard1:UpdateGUI()
			splitCard2:UpdateGUI()

			Game_24.Hide_Operators(newCard)
			newCard._cardObject:Destroy() -- destroy card selected
			table.remove(Game_Cards, table.find(Game_Cards, newCard))
			table.insert(Game_Cards, splitCard1)
			table.insert(Game_Cards, splitCard2)

			Game_24.Card_Functionality(splitCard1, model, Game_Cards)
			splitCard1._cardObject.Parent = model.CardFolder
			Game_24.Card_Functionality(splitCard2, model, Game_Cards)
			splitCard2._cardObject.Parent = model.CardFolder
		end)
	end
end

Game_24.Hide_Operators = function(card)
	if card._operatorSetObject then
		card._operatorSetObject:CleanUp()
		card._operatorSetObject = nil -- allow garbage collection for operatorSet
	end
end

Game_24.Card_Functionality = function(card, model, Game_Cards)
	local tweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In) -- TODO: utilities this
	print("Card selection functionality adding")

	local ClickDetector = card._cardObject.ClickDetector
	ClickDetector.MouseClick:Connect(function()
		local operatorIsSelected = false
		local cardSelected = false
		local otherCard
		-- check if another card has already been selected
		for _, v in pairs(Game_Cards) do
			if v._selected then
				print("Card is already selected")
				cardSelected = true
				break
			end
		end
		-- check if an operator has already been selected
		for _, v in pairs(Game_Cards) do
			if v._operatorSetObject and v._operatorSetObject._operatorSelectedName ~= nil then
				operatorIsSelected = true
				otherCard = v
				break
			end
		end

		if cardSelected and operatorIsSelected then--detect if an operator is selected then
			if card._selected then -- card selected is self (deselect self)
				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				Game_24.Hide_Operators(card)
			else
				print("combine!!!")
				-- set card values to a new CardObject
				local combinedCard = CardObject.new()
				combinedCard._cardTable[1] = otherCard._operatorSetObject._operatorSelectedName
				combinedCard._cardTable[2] = otherCard._cardTable
				combinedCard._cardTable[3] = card._cardTable
				
				--combinedCard._combinedCard = true [ we can tell if a card is a _combinedCard by checking table ]
				
				local combinedCardObject = Base_Card:Clone()
				combinedCard._cardObject = combinedCardObject
				
				--remove cards from game_cards and folder, then add to game_cards and lastly the folder
				table.remove(Game_Cards, table.find(Game_Cards, card))
				table.remove(Game_Cards, table.find(Game_Cards, otherCard))
				table.insert(Game_Cards, combinedCard)
				print(Game_Cards)
				Game_24.Hide_Operators(otherCard)
				card._cardObject:Destroy()
				otherCard._cardObject:Destroy()
				
				combinedCard:UpdateGUI()
				Game_24.Card_Functionality(combinedCard, model, Game_Cards) -- give new card functionality
				combinedCardObject.Parent = model.CardFolder
			end
		elseif cardSelected then
			if card._selected then -- card is selected and that card is this one (deselect self)
				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				Game_24.Hide_Operators(card)
			else -- card is selected but not this one (select self, deselect other)
				for _, v in pairs(Game_Cards) do
					if v ~= card then
						v._selected = false
						local hoverTween = TweenService:Create(v._cardObject, tweenInfo, {Position = v._startingPosition})
						hoverTween:Play()
						Game_24.Hide_Operators(v)
					end
				end
				card._selected = true
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
				hoverTween:Play()
				Reveal_Operators(card, model, Game_Cards)
			end
		else -- no card currently selected (select self)
			card._selected = true
			local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
			hoverTween:Play()
			Reveal_Operators(card, model, Game_Cards)
		end
	end)
end

local function Cleanup(promptObject)
	-- enable promptObject again
	promptObject.Enabled = true -- TODO: move to a cleanup function
	-- clean up and destroy cards
	-- clean up folderAdded connection
	-- give player controls back

end

function Game_24.initialize(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")
	print(player.Name)
	-- Move player to position
	player.Character:WaitForChild("HumanoidRootPart").Position = ancestorModel:GetAttribute("move_to_position") -- config
	-- Lock player movements
	--LockMovementRE:FireClient(player)
	-- Move player camers
	-- Lock player camera
	-- Disable proximityPrompt (one user at a time)
	promptObject.Enabled = false
	-- Tie cleanup events to death and leave
	local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		Cleanup(promptObject)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			Cleanup(promptObject)
			playerLeaveConnection:Disconnect()
		end
	end)

    -- Initialize game cards and connections
    local Game_Cards = {}

	-- Pull a question -- TODO: work in difficulties
	local cardPulled = CardList[math.random(1, #CardList)]

	-- Form to board
	local BoardCards = ancestorModel.BoardCards
	local counter = 1
	for _, v in pairs(BoardCards:GetDescendants()) do -- TODO: Change to utility function and add VFX
		if v:IsA("TextLabel") then
			v.Text = "<u>" .. tostring(cardPulled[counter]) .. "</u>"
			counter = counter + 1
		end
	end

	-- Make cards reposition when a new card is added
	local CardFolder = ancestorModel.CardFolder
	local gapSize = 4 --TODO: change to dynamic
	local originalOriginPosition = ancestorModel:GetAttribute("origin_position") -- TODO: change to dynamic
	local cardAddedConnection
	cardAddedConnection = CardFolder.ChildAdded:Connect(function()
		local iterator = 0
		local origin = originalOriginPosition - (Vector3.new(0, 0, (.5)*(#CardFolder:GetChildren() - 1) * gapSize))
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
					wait(1)
					Game_24.deInitialize(promptObject, Game_Cards)
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
		Game_24.Card_Functionality(v, ancestorModel, Game_Cards)
	end
end

function Game_24.deInitialize(promptObject, Game_Cards)
	-- remove cards, etc. etc.
	for _, v in pairs(Game_Cards) do
		Game_24.Hide_Operators(v)
		v._cardObject:Destroy()
	end

	table.clear(Game_Cards)
	Game_Cards = nil -- allow cleanup
	
	promptObject.Enabled = true
	Cleanup(promptObject)
end

return Game_24
