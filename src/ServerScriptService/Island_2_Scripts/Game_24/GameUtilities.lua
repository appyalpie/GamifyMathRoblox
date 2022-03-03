local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local CardObject = require(script.Parent.CardObject)
local OperatorSetObject = require(script.Parent.OperatorSetObject)

local GameInfo = require(script.Parent.Parent.GameInfo)
local TweenUtilities = require(script.Parent.Parent.Parent.Utilities.TweenUtilities)

local Operator_Set_Model = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set_Model")
local Level1_Card_Model = ServerStorage.Island_2.Game_24:WaitForChild("Level1_Card_Model")
local Level2_Card_Model = ServerStorage.Island_2.Game_24:WaitForChild("Level2_Card_Model")
local Level3_Card_Model = ServerStorage.Island_2.Game_24:WaitForChild("Level3_Card_Model")
local Level4_Card_Model = ServerStorage.Island_2.Game_24:WaitForChild("Level4_Card_Model")

local Card_Model_Table = {
    [1] = Level1_Card_Model,
    [2] = Level2_Card_Model,
    [3] = Level3_Card_Model,
    [4] = Level4_Card_Model
}

--[[
    local Operator_Set = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set")
    local Base_Card = ServerStorage.Island_2.Game_24:WaitForChild("Base_Card")
]]


local GameUtilities = {}

--returns a cloned card based on what depth is passed in
GameUtilities.Get_Card_Clone_From_Depth = function(depth)
    return Card_Model_Table[depth]:Clone()
end

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
	newOperatorSetObject._operatorSet = Operator_Set_Model:Clone()
	-- set the card's operators to the new object
	newCard._operatorSetObject = newOperatorSetObject
	
	local operatorSet = newOperatorSetObject._operatorSet -- label for ease of access
	operatorSet.Parent = game.Workspace -- TODO: set to somewhere else
	local offset = Vector3.new(0,5.5,0)
	operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset))
	newOperatorSetObject._cardPositionChangedSignal = newCard._cardObject.PrimaryPart:GetPropertyChangedSignal("Position"):Connect(function()
		operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset))
	end)
	
	-- Make Operator Selectable
	newOperatorSetObject._addClickDetectorSignal = operatorSet.Add.Union.ClickDetector.MouseClick:Connect(function(player)
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
	newOperatorSetObject._subtractClickDetectorSignal = operatorSet.Subtract.Union.ClickDetector.MouseClick:Connect(function(player)
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
	newOperatorSetObject._multiplyClickDetectorSignal = operatorSet.Multiply.Union.ClickDetector.MouseClick:Connect(function(player)
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
	newOperatorSetObject._divideClickDetectorSignal = operatorSet.Divide.Union.ClickDetector.MouseClick:Connect(function(player)
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
		operatorSet.Undo.Union.Transparency = 0
		newOperatorSetObject._undoClickDetectorSignal = operatorSet.Undo.Union.ClickDetector.MouseClick:Connect(function(player)
            if player ~= CurrentGameInfo.currentPlayer then return end -- check if player is the player in game
			-- split card into two cards
			local splitCard1 = CardObject.new()
			splitCard1._cardTable = newCard._cardTable[2] -- reference
			splitCard1._cardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(splitCard1._cardTable))
			local splitCard2 = CardObject.new()
			splitCard2._cardTable = newCard._cardTable[3] -- reference
			splitCard2._cardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(splitCard2._cardTable))

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

	local ClickDetector = card._cardObject.Base_Card.ClickDetector
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
				local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				GameUtilities.Hide_Operators(card)
			else
				-- set card values to a new CardObject
				local combinedCard = CardObject.new()
				combinedCard._cardTable[1] = otherCard._operatorSetObject._operatorSelectedName
				combinedCard._cardTable[2] = otherCard._cardTable
				combinedCard._cardTable[3] = card._cardTable
				
				--combinedCard._combinedCard = true [ we can tell if a card is a _combinedCard by checking table ]
				
				local combinedCardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(combinedCard._cardTable))
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
                -- disable click detectors while the combine is occuring
                local cardBase = card._cardObject.Base_Card
                local otherCardBase = otherCard._cardObject.Base_Card
                cardBase.ClickDetector:Destroy()
                otherCardBase.ClickDetector:Destroy()

                --[[ Combine effects simplified
                1. Get midpoint of two cards
                2. Translate card with some trail effects
                ]]
                
                local targetCFrame = cardBase.CFrame:Lerp(otherCardBase.CFrame, .5) + Vector3.new(0,5,0)
                local tweenCard = TweenService:Create(cardBase, GameInfo.CombineTweenInfo, {Position = targetCFrame.Position})
                local tweenOtherCard = TweenService:Create(otherCardBase, GameInfo.CombineTweenInfo, {Position = targetCFrame.Position})
                tweenOtherCard.Completed:Connect(function()
                    card._cardObject:Destroy()
                    otherCard._cardObject:Destroy()
                    
                    combinedCard:UpdateGUI()
                    GameUtilities.Card_Functionality(combinedCard, model, Game_Cards, CurrentGameInfo) -- give new card functionality
                    combinedCardObject.Parent = model.CardFolder
                end)
                tweenCard:Play()
                tweenOtherCard:Play()
                --[[ TODO: Combine effects with SPLINE or Bezier
                1. Calculate three points
                2. Interpolate
                ]]

                --[[ Combine effects using multiTweenFunction
                1. Get midpoint of two cards
                2. Tween Y ([Quad, Quart, Quint], Out)
                3. Tween XZ (Back, In)
                ]]
                --[[
                    local yTweenCard = TweenUtilities.multiTweenFunction(GameInfo.CombineYDirectionTweenInfo, function(t)
                        cardBase.Position = Vector3.new(cardBase.Position.X, cardBase.Position.Y + (t * (targetCFrame.Position.Y - cardBase.Position.Y)), cardBase.Position.Z)
                    end)
                    local yTweenOtherCard = TweenUtilities.multiTweenFunction(GameInfo.CombineYDirectionTweenInfo, function(t)
                        otherCardBase.Position = Vector3.new(otherCardBase.Position.X, 
                        otherCardBase.Position.Y + (t * (targetCFrame.Position.Y - otherCardBase.Position.Y)), otherCardBase.Position.Z)
                    end)
                    local xzTweenCard = TweenUtilities.multiTweenFunction(GameInfo.CombineXZDirectionTweenInfo, function(t)
                        cardBase.Position = Vector3.new(cardBase.Position.X + (t * (targetCFrame.Position.X - cardBase.Position.X)),
                        cardBase.Position.Y, cardBase.Position.Z + (t * (targetCFrame.Position.Z - cardBase.Position.Z)))
                    end)
                    local xzTweenOtherCard = TweenUtilities.multiTweenFunction(GameInfo.CombineXZDirectionTweenInfo, function(t)
                        otherCardBase.Position = Vector3.new(otherCardBase.Position.X + (t * (targetCFrame.Position.X - otherCardBase.Position.X)),
                        otherCardBase.Position.Y, otherCardBase.Position.Z + (t * (targetCFrame.Position.Z - otherCardBase.Position.Z)))
                    end)
                    yTweenCard:Play()
                    yTweenOtherCard:Play()
                    xzTweenCard:Play()
                    xzTweenOtherCard:Play()

                    xzTweenOtherCard.Completed:Connect(function()
                        card._cardObject:Destroy()
                        otherCard._cardObject:Destroy()
                        
                        combinedCard:UpdateGUI()
                        GameUtilities.Card_Functionality(combinedCard, model, Game_Cards, CurrentGameInfo) -- give new card functionality
                        combinedCardObject.Parent = model.CardFolder
                    end)
                ]]
			end
		elseif cardSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (select another)
			if card._selected then
				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				GameUtilities.Hide_Operators(card)
			else
				for _, v in pairs(Game_Cards) do
					if v ~= card then
						v._selected = false
						local hoverTween = TweenService:Create(v._cardObject.PrimaryPart, tweenInfo, {Position = v._startingPosition})
						hoverTween:Play()
						GameUtilities.Hide_Operators(v)
					end
				end
				card._selected = true
				local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
				hoverTween:Play()
				GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
			end
		else -- select a card
			card._selected = true
			local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
			hoverTween:Play()
			GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
		end
	end)
end

return GameUtilities