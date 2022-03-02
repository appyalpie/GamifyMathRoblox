local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local CardObject = require(script.Parent.CardObject)
local OperatorSetObject = require(script.Parent.OperatorSetObject)

local Operator_Set = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set")
local Base_Card = ServerStorage.Island_2.Game_24:WaitForChild("Base_Card")

local GameUtilities = {}

--TODO: add VFX
GameUtilities.Board_Initialization = function(BoardCards, cardPulled)
    local counter = 1
    for _, v in pairs(BoardCards:GetDescendants()) do
		if v:IsA("TextLabel") then
			v.Text = "<u>" .. tostring(cardPulled[counter]) .. "</u>"
			counter = counter + 1
		end
	end
end

GameUtilities.Reveal_Operators = function(newCard, model, Game_Cards, CurrentGameInfo)
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
	newOperatorSetObject._addClickDetectorSignal = operatorSet.Add.ClickDetector.MouseClick:Connect(function(player)
        if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
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
	newOperatorSetObject._subtractClickDetectorSignal = operatorSet.Subtract.ClickDetector.MouseClick:Connect(function(player)
        if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
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
	newOperatorSetObject._multiplyClickDetectorSignal = operatorSet.Multiply.ClickDetector.MouseClick:Connect(function(player)
        if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
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
	newOperatorSetObject._divideClickDetectorSignal = operatorSet.Divide.ClickDetector.MouseClick:Connect(function(player)
        if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
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
		newOperatorSetObject._undoClickDetectorSignal = operatorSet.Undo.ClickDetector.MouseClick:Connect(function(player)
            if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
			-- split card into two cards
			local splitCard1 = CardObject.new()
			splitCard1._cardTable = newCard._cardTable[2] -- reference
			splitCard1._cardObject = Base_Card:Clone()
			local splitCard2 = CardObject.new()
			splitCard2._cardTable = newCard._cardTable[3] -- reference
			splitCard2._cardObject = Base_Card:Clone()

			splitCard1:UpdateGUI()
			splitCard2:UpdateGUI()

			GameUtilities.Hide_Operators(newCard)
			newCard._cardObject:Destroy() -- destroy card selected

			local indexOfRemovedCard = table.find(Game_Cards, newCard)
			table.remove(Game_Cards, indexOfRemovedCard)
			table.insert(Game_Cards, indexOfRemovedCard, splitCard1)
			table.insert(Game_Cards, indexOfRemovedCard + 1, splitCard2)

			GameUtilities.Card_Functionality(splitCard1, model, Game_Cards, CurrentGameInfo)
			splitCard1._cardObject.Parent = model.CardFolder
			GameUtilities.Card_Functionality(splitCard2, model, Game_Cards, CurrentGameInfo)
			splitCard2._cardObject.Parent = model.CardFolder
		end)
	end
end

GameUtilities.Hide_Operators = function(card)
	if card._operatorSetObject then
		card._operatorSetObject:CleanUp()
		card._operatorSetObject = nil -- allow garbage collection for operatorSet
	end
end

GameUtilities.Card_Functionality = function(card, model, Game_Cards, CurrentGameInfo)
	local tweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In) -- TODO: utilities this
	--print("Card selection functionality adding")

	local ClickDetector = card._cardObject.ClickDetector
	ClickDetector.MouseClick:Connect(function(player)
        if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game

		local operatorIsSelected = false
		local cardSelected = false
		local otherCard
		-- check if another card has already been selected
		for _, v in pairs(Game_Cards) do
			if v._selected then
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
        --print("Is card selected? " .. tostring(cardSelected) .. " |?| Is operator selected? " .. tostring(operatorIsSelected))

		if cardSelected and operatorIsSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (combine)
			if card._selected then
				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				GameUtilities.Hide_Operators(card)
			else
				-- set card values to a new CardObject
				local combinedCard = CardObject.new()
				combinedCard._cardTable[1] = otherCard._operatorSetObject._operatorSelectedName
				combinedCard._cardTable[2] = otherCard._cardTable
				combinedCard._cardTable[3] = card._cardTable
				
				--combinedCard._combinedCard = true [ we can tell if a card is a _combinedCard by checking table ]
				
				local combinedCardObject = Base_Card:Clone()
				combinedCard._cardObject = combinedCardObject
				
				--remove cards from game_cards and folder, then add to game_cards and lastly the folder
				local indexOfCard = table.find(Game_Cards, card)
				local indexOfOtherCard = table.find(Game_Cards, otherCard)
				local newIndex = math.floor((indexOfCard + indexOfOtherCard) / 2)

                if indexOfCard > indexOfOtherCard then -- remove in correct order
                    table.remove(Game_Cards, indexOfCard)
				    table.remove(Game_Cards, indexOfOtherCard)
                else
                    table.remove(Game_Cards, indexOfOtherCard)
                    table.remove(Game_Cards, indexOfCard)
                end
				table.insert(Game_Cards, newIndex, combinedCard)
                
				GameUtilities.Hide_Operators(otherCard)
				card._cardObject:Destroy()
				otherCard._cardObject:Destroy()
				
				combinedCard:UpdateGUI()
				GameUtilities.Card_Functionality(combinedCard, model, Game_Cards, CurrentGameInfo) -- give new card functionality
				combinedCardObject.Parent = model.CardFolder
			end
		elseif cardSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (select another)
			if card._selected then
				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				GameUtilities.Hide_Operators(card)
			else
				for _, v in pairs(Game_Cards) do
					if v ~= card then
						v._selected = false
						local hoverTween = TweenService:Create(v._cardObject, tweenInfo, {Position = v._startingPosition})
						hoverTween:Play()
						GameUtilities.Hide_Operators(v)
					end
				end
				card._selected = true
				local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
				hoverTween:Play()
				GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
			end
		else -- select a card
			card._selected = true
			local hoverTween = TweenService:Create(card._cardObject, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
			hoverTween:Play()
			GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
		end
	end)
end

return GameUtilities