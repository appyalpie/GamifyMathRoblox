local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardObject = require(script.Parent.CardObject)
local OperatorSetObject = require(script.Parent.OperatorSetObject)

local GameInfo = require(script.Parent.Parent.GameInfo)
--local TweenUtilities = require(script.Parent.Parent.Parent.Utilities.TweenUtilities)
local SphereUtilities = require(script.Parent.Parent.Parent.Utilities.SphereUtilities)
local GameStatsUtilities = require(ServerScriptService.GameStatsInitialization.GameStatsUtilities)

local TitleModule = require(game.ServerScriptService:WaitForChild("TitleModule"))

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

local Energyball = ServerStorage.Island_2.Game_24:WaitForChild("Energyball")
local Fireball = ServerStorage.Island_2.Game_24:WaitForChild("Fireball")
local Combine_Core = ServerStorage.Island_2.Game_24:WaitForChild("Combine_Core")
local Explosion_Core = ServerStorage.Island_2.Game_24:WaitForChild("Explosion_Core")

------ Title Binding Remote Events ------
local PlayerSideShowNameAndTitleEvent = game.ReplicatedStorage:WaitForChild('PlayerSideHideNameAndTitleEvent')
local PlayerSideHideNameAndTitleEvent = game.ReplicatedStorage:WaitForChild('PlayerSideHideNameAndTitleEvent')

------ Camera Remote Events ------
local CameraPointToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraPointToRE")
local CameraFollowRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraFollowRE")
local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

------ Victory Defeat GUI Remote Events ------
local VictoryEventRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("VictoryEventRE")
local DefeatEventRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("DefeatEventRE")

--[[
    local Operator_Set = ServerStorage.Island_2.Game_24:WaitForChild("Operator_Set")
    local Base_Card = ServerStorage.Island_2.Game_24:WaitForChild("Base_Card")
]]


local GameUtilities = {}

GameUtilities.Set_Orientation = function(part, orientation)
	part.Orientation = Vector3.new(part.Orientation.X, orientation, part.Orientation.Z)
end

GameUtilities.Get_Starting_Position = function(center, gap, index, numberPresent, theta)
	--local origin = center - (Vector3.new(0, 0, (.5)*(numberPresent - 1) * gap))
	local offset = Vector3.new(math.sin(theta) * gap, 0,  math.cos(theta) * gap)
	local origin = center + (Vector3.new((.5) * (numberPresent - 1), 0, (.5) * (numberPresent - 1)) * offset)
	return origin - (Vector3.new(index, 0, index) * offset)
end

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
			v.Parent.Parent:SetAttribute("value", cardPulled[counter])
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
	operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset)
		* CFrame.Angles(0, CurrentGameInfo._orientation + math.pi, 0))
	newOperatorSetObject._cardPositionChangedSignal = newCard._cardObject.PrimaryPart:GetPropertyChangedSignal("Position"):Connect(function()
		operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset) 
		* CFrame.Angles(0, CurrentGameInfo._orientation + math.pi, 0))
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
			CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.CameraMoveTime)
			-- split card into two cards
			local splitCard1 = CardObject.new()
			splitCard1._cardTable = newCard._cardTable[2] -- reference
			splitCard1._cardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(splitCard1._cardTable))
			GameUtilities.Set_Orientation(splitCard1._cardObject.PrimaryPart, CurrentGameInfo._orientationDegrees)
			
			local splitCard2 = CardObject.new()
			splitCard2._cardTable = newCard._cardTable[3] -- reference
			splitCard2._cardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(splitCard2._cardTable))
			GameUtilities.Set_Orientation(splitCard2._cardObject.PrimaryPart, CurrentGameInfo._orientationDegrees)

			splitCard1:UpdateGUI()
			splitCard2:UpdateGUI()

			GameUtilities.Hide_Operators(newCard)
			
			local newCardBase = newCard._cardObject.Base_Card
			newCard._cardObject.Base_Card.ClickDetector:Destroy() -- destroy click detector of card selected
			
			--local destroyOnSplitTween = TweenService:Create(newCard._cardObject.PrimaryPart, GameInfo.DestroySplitTweenInfo, {})
			-- Effects: 1. Card squeezed, 2. Get position of new cards 3.Energyballs fly out to the card positions, new cards are added in w/o click functionality yet
			-- 4. tween transparency in and add click functionality 
			local indexOfRemovedCard = table.find(Game_Cards, newCard)

			table.remove(Game_Cards, indexOfRemovedCard)
			table.insert(Game_Cards, indexOfRemovedCard, splitCard1)
			table.insert(Game_Cards, indexOfRemovedCard + 1, splitCard2)

			local energyBall1 = Energyball:Clone()
			energyBall1.Position = newCard._cardObject.PrimaryPart.Position
			energyBall1.Parent = game.Workspace
			local positionOfSplit1 = GameUtilities.Get_Starting_Position(CurrentGameInfo._originalOriginPosition,
				4, indexOfRemovedCard, #(CurrentGameInfo._cardFolder:GetChildren())+3, CurrentGameInfo._orientation) --???
			Debris:AddItem(energyBall1, 3)

			local energyBall2 = Energyball:Clone()
			energyBall2.Position = newCard._cardObject.PrimaryPart.Position
			energyBall2.Parent = game.Workspace
			local positionOfSplit2 = GameUtilities.Get_Starting_Position(CurrentGameInfo._originalOriginPosition,
				4, indexOfRemovedCard + 1, #(CurrentGameInfo._cardFolder:GetChildren())+3, CurrentGameInfo._orientation)
			Debris:AddItem(energyBall2, 3)

			energyBall1.Sounds.Magical:Play()
			energyBall2.Sounds.Magical:Play()

			local basePhi = SphereUtilities.getXY(positionOfSplit1, newCardBase.Position)
			local baseTheta = SphereUtilities.getXZ(positionOfSplit1, newCardBase.Position)
			local baseDistance = 0
			local baseDistanceValue = Instance.new("NumberValue")
			baseDistanceValue.Value = baseDistance
			baseDistanceValue.Parent = energyBall1

			local otherPhi = SphereUtilities.getXY(positionOfSplit2, newCardBase.Position)
			local otherTheta = SphereUtilities.getXZ(positionOfSplit2, newCardBase.Position)
			local otherDistance = 0
			local otherDistanceValue = Instance.new("NumberValue")
			otherDistanceValue.Value = otherDistance
			baseDistanceValue.Parent = energyBall2

			local squeezeTween = TweenService:Create(newCard._cardObject.Base_Card, GameInfo.DestroySplitTweenInfo, 
				{Orientation = newCard._cardObject.Base_Card.Orientation + Vector3.new(math.random(-120,120),math.random(-120,120),math.random(-120,120)),
				Transparency = .8, Size = Vector3.new(.1, .5, .3)})

			for _, v in pairs(newCard._cardObject:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end

			squeezeTween.Completed:Connect(function()
				local phiIncrement = .1
				local baseCounter = 0
				local otherCounter = 0
				local baseDistanceValueTween = TweenService:Create(baseDistanceValue, GameInfo.MoveSplitTweenInfo, 
					{Value = SphereUtilities.getDistance(positionOfSplit1, newCardBase.Position)})
				baseDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
					energyBall1.Position = SphereUtilities.sphereToRect2(baseDistanceValue.Value, basePhi + (phiIncrement * baseCounter), baseTheta, newCardBase.Position)
					baseCounter = baseCounter + 1
				end)
				local otherDistanceValueTween = TweenService:Create(otherDistanceValue, GameInfo.MoveSplitTweenInfo, 
					{Value = SphereUtilities.getDistance(positionOfSplit1, newCardBase.Position)})
				otherDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
					energyBall2.Position = SphereUtilities.sphereToRect2(otherDistanceValue.Value, otherPhi + (phiIncrement * otherCounter), otherTheta, newCardBase.Position)
					otherCounter = otherCounter + 1
				end)
				baseDistanceValueTween.Completed:Connect(function()
					-- explosion and destroy
					--[[
					for _, v in pairs(combineCore.Attachment:GetChildren()) do
						v.Enabled = false
					end
					combineCore.Sparks.Enabled = false
					combineCore.Explosion_Random:Emit(50)
					combineCore.Stars:Emit(50)
					]]
					--energyBall1:Destroy()
					--energyBall2:Destroy()
					for _, v in pairs(energyBall1.CoreAttachment:GetChildren()) do
						v.Enabled = false
					end
					for _, v in pairs(energyBall2.CoreAttachment:GetChildren()) do
						v.Enabled = false
					end

					newCard._cardObject:Destroy() -- destroy card selected

					splitCard1._cardObject.Base_Card.Transparency = 1
					splitCard2._cardObject.Base_Card.Transparency = 1
					splitCard1._cardObject.Base_Card.SurfaceGui.TextLabel.TextTransparency = 1
					splitCard2._cardObject.Base_Card.SurfaceGui.TextLabel.TextTransparency = 1

					splitCard1._cardObject.Parent = CurrentGameInfo._cardFolder
					splitCard2._cardObject.Parent = CurrentGameInfo._cardFolder

					local splitCard1Tween = TweenService:Create(splitCard1._cardObject.Base_Card, GameInfo.SplitCardTweenInfo, {Transparency = 0})
					local splitCard2Tween = TweenService:Create(splitCard2._cardObject.Base_Card, GameInfo.SplitCardTweenInfo, {Transparency = 0})
					local splitCard1TextTween = TweenService:Create(splitCard1._cardObject.Base_Card.SurfaceGui.TextLabel, 
						GameInfo.SplitCardTweenInfo, {TextTransparency = 0})
					local splitCard2TextTween = TweenService:Create(splitCard2._cardObject.Base_Card.SurfaceGui.TextLabel, 
						GameInfo.SplitCardTweenInfo, {TextTransparency = 0})

					splitCard1._cardObject.Base_Card.Position = positionOfSplit1
					splitCard2._cardObject.Base_Card.Position = positionOfSplit2

					splitCard1Tween.Completed:Connect(function()
						energyBall1.Sounds.Sparkle:Play()
						energyBall2.Sounds.Sparkle:play()

						energyBall1.Stars:Emit(25)
						energyBall2.Stars:Emit(25)
						GameUtilities.Card_Functionality(splitCard1, model, Game_Cards, CurrentGameInfo)
						GameUtilities.Card_Functionality(splitCard2, model, Game_Cards, CurrentGameInfo)
					end)
					splitCard1TextTween:Play()
					splitCard2TextTween:Play()
					splitCard1Tween:Play()
					splitCard2Tween:Play()
				end)
				energyBall1.Sounds.Air_Woosh_Long:Play()
				energyBall2.Sounds.Air_Woosh_Long:Play()

				baseDistanceValueTween:Play()
				otherDistanceValueTween:Play()
			end)
			squeezeTween:Play()
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

	local ClickDetector = card._cardObject:WaitForChild("Base_Card"):WaitForChild("ClickDetector")
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
        --print("Is card selected? " .. tostring(cardS elected) .. " |?| Is operator selected? " .. tostring(operatorIsSelected))

		if cardSelected and operatorIsSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (combine)
			if card._selected then
				CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.CameraMoveTime)
				card._cardObject.Base_Card.Sounds.Roblox_Button_Sound_Effect:Play() -- sound effect

				card._selected = false
				local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition})
				hoverTween:Play()
				GameUtilities.Hide_Operators(card)
			elseif CardObject.calculateValue(card._cardTable) == 0 and otherCard._operatorSetObject._operatorSelectedName == "divide" then -- no divide by 0
				card._cardObject.Base_Card.Sounds.Wrong:Play()
				return
			else
				CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.CameraMoveTime)
				-- set card values to a new CardObject
				local combinedCard = CardObject.new()
				combinedCard._cardTable[1] = otherCard._operatorSetObject._operatorSelectedName
				combinedCard._cardTable[2] = otherCard._cardTable
				combinedCard._cardTable[3] = card._cardTable
				
				--combinedCard._combinedCard = true [ we can tell if a card is a _combinedCard by checking table ]
				
				local combinedCardObject = GameUtilities.Get_Card_Clone_From_Depth(CardObject.maxDepth(combinedCard._cardTable))
				combinedCard._cardObject = combinedCardObject
				GameUtilities.Set_Orientation(combinedCardObject.PrimaryPart, CurrentGameInfo._orientationDegrees)
				
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

				--[[ Combine effects (sphereical coordinates)
				1. Get midpoint of two cards
				1.5. Combine_Core in the midpoint
				2. Transform cards into energy ball effects
				]]
				local targetCFrame = cardBase.CFrame:Lerp(otherCardBase.CFrame, .5) + Vector3.new(0,5,0)

				local combineCore = Combine_Core:Clone()
				combineCore.Position = targetCFrame.Position
				combineCore.Parent = game.Workspace
				Debris:AddItem(combineCore, 5)
				
				local energyBall1 = Energyball:Clone()
				energyBall1.Position = card._cardObject.PrimaryPart.Position
				energyBall1.Parent = game.Workspace

				local energyBall2 = Energyball:Clone()
				energyBall2.Position = otherCard._cardObject.PrimaryPart.Position
				energyBall2.Parent = game.Workspace

				local basePhi = SphereUtilities.getXY(cardBase.Position, targetCFrame.Position)
				local baseTheta = SphereUtilities.getXZ(cardBase.Position, targetCFrame.Position)
				local baseDistance = SphereUtilities.getDistance(cardBase.Position, targetCFrame.Position)
				local baseDistanceValue = Instance.new("NumberValue")
				baseDistanceValue.Value = baseDistance
				baseDistanceValue.Parent = energyBall1

				local otherPhi = SphereUtilities.getXY(otherCardBase.Position, targetCFrame.Position)
				local otherTheta = SphereUtilities.getXZ(otherCardBase.Position, targetCFrame.Position)
				local otherDistance = SphereUtilities.getDistance(otherCardBase.Position, targetCFrame.Position)
				local otherDistanceValue = Instance.new("NumberValue")
				otherDistanceValue.Value = otherDistance
				baseDistanceValue.Parent = energyBall2

				energyBall1.Position = SphereUtilities.sphereToRect2(baseDistance, basePhi, baseTheta, targetCFrame.Position)
				energyBall2.Position = SphereUtilities.sphereToRect2(otherDistance, otherPhi, otherTheta, targetCFrame.Position)

				-- effects
				local combineTweenInfo = TweenInfo.new(1)
				local squeezeTweenInfo = TweenInfo.new(.5)
				-- cards are morphed into balls, tween orientation + transparency + size
				local squeezeCardTween = TweenService:Create(cardBase, squeezeTweenInfo, 
					{Orientation = cardBase.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60)),
					Transparency = .8, Size = Vector3.new(.1, .5, .3)})
				local squeezeOtherCardTween = TweenService:Create(otherCardBase, squeezeTweenInfo, 
					{Orientation = cardBase.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60)),
					Transparency = .8, Size = Vector3.new(.1, .5, .3)})

				squeezeOtherCardTween.Completed:Connect(function()
					card._cardObject:Destroy()
                	otherCard._cardObject:Destroy()
					
					local phiIncrement = math.random(5,15) * .01
					local baseCounter = 0
					local otherCounter = 0
					local baseDistanceValueTween = TweenService:Create(baseDistanceValue, combineTweenInfo, {Value = 0})
					baseDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
						energyBall1.Position = SphereUtilities.sphereToRect2(baseDistanceValue.Value, basePhi + (phiIncrement * baseCounter), baseTheta, targetCFrame.Position)
						baseCounter = baseCounter + 1
					end)
					local otherDistanceValueTween = TweenService:Create(otherDistanceValue, combineTweenInfo, {Value = 0})
					otherDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
						energyBall2.Position = SphereUtilities.sphereToRect2(otherDistanceValue.Value, otherPhi + (phiIncrement * otherCounter), otherTheta, targetCFrame.Position)
						otherCounter = otherCounter + 1
					end)
					baseDistanceValueTween.Completed:Connect(function()
						-- explosion and destroy
						for _, v in pairs(combineCore.Attachment:GetChildren()) do
							v.Enabled = false
						end
						combineCore.Sounds.Sparkle:Play()

						-- make completion sounds pitch shift based on card level
						local pitchShift = combineCore.Sounds.Combine_Sound_Effect.PitchShift
						if combinedCard._cardObject.name == "Level3_Card_Model" then
							pitchShift.Octave = 1.25
							combineCore.Sounds.Combine_Sound_Effect.Volume = 0.7
						elseif combinedCard._cardObject.name == "Level4_Card_Model" then
							pitchShift.Octave = 1.5
							combineCore.Sounds.Combine_Sound_Effect.Volume = 0.9
						end
						combineCore.Sounds.Combine_Sound_Effect:Play()

						combineCore.Sparks.Enabled = false
						combineCore.Explosion_Random:Emit(50)
						combineCore.Stars:Emit(50)
						energyBall1:Destroy()
						energyBall2:Destroy()
						
						combinedCard:UpdateGUI()
						GameUtilities.Card_Functionality(combinedCard, model, Game_Cards, CurrentGameInfo) -- give new card functionality
						combinedCardObject.PrimaryPart.Position = targetCFrame.Position 
						combinedCardObject.Parent = CurrentGameInfo._cardFolder
					end)
					energyBall1.Sounds.Air_Woosh_Long:Play()
					energyBall2.Sounds.Air_Woosh_Long:Play()
					baseDistanceValueTween:Play()
					otherDistanceValueTween:Play()
					--[[
						local energyBall1Tween = TweenService:Create(energyBall1, combineTweenInfo, {Position = targetCFrame.Position})
						
						local energyBall2Tween = TweenService:Create(energyBall2, combineTweenInfo, {Position = targetCFrame.Position})
						energyBall1Tween:Play()
						energyBall2Tween:Play()
						energyBall1Tween.Completed:Connect(function()
							energyBall1:Destroy()
							energyBall2:Destroy()
							
							combinedCard:UpdateGUI()
							GameUtilities.Card_Functionality(combinedCard, model, Game_Cards, CurrentGameInfo) -- give new card functionality
							combinedCardObject.PrimaryPart.Position = targetCFrame.Position 
							combinedCardObject.Parent = model.CardFolder
						end)
					]]
				end)
				squeezeCardTween:Play()
				squeezeOtherCardTween:Play()

				

                --[[ Combine effects simplified
                1. Get midpoint of two cards
                2. Translate card with some trail effects
                ]]
                
				--[[
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
				]]
                
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
				CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.CameraMoveTime)
				card._cardObject.Base_Card.Sounds.Roblox_Button_Sound_Effect:Play()

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
				CameraPointToRE:FireClient(player, card._cardObject.Base_Card, GameInfo.CameraMoveTime)
				card._cardObject.Base_Card.Sounds.Click_Sound_Effect:Play()

				card._selected = true
				local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
				hoverTween:Play()
				GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
			end
		else -- select a card
			CameraPointToRE:FireClient(player, card._cardObject.Base_Card, GameInfo.CameraMoveTime)
			card._cardObject.Base_Card.Sounds.Click_Sound_Effect:Play()

			card._selected = true
			local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, tweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
			hoverTween:Play()
			GameUtilities.Reveal_Operators(card, model, Game_Cards, CurrentGameInfo)
		end
	end)
end

GameUtilities.Win_Sequence = function(Game_Cards, CurrentGameInfo, finishedWinSequenceEvent, player)
	VictoryEventRE:FireClient(player)
	--[[
	1. Get equation from last card
	]]
	local winningCard = Game_Cards[1]
	local winningCardTable = winningCard._cardTable
	local winningSequence = {}
	local winningString = CardObject.getSequence(winningCardTable)
	print(winningString)

	-- GameStats Changes
	GameUtilities.IncrementStats(CurrentGameInfo._difficulty, winningString, player, CurrentGameInfo._opponentName)

	local startIndex = 1
	while startIndex <= string.len(winningString) do
		local character = string.sub(winningString, startIndex, startIndex)
		if tonumber(character) ~= nil then
			local startOfNumber = startIndex
			local endOfNumber = startIndex
			while tonumber(string.sub(winningString, startIndex + 1, startIndex + 1)) ~= nil do
				startIndex = startIndex + 1
				endOfNumber = startIndex
			end
			table.insert(winningSequence, tonumber(string.sub(winningString, startOfNumber, endOfNumber)))
		else
			table.insert(winningSequence, character)
		end
		startIndex = startIndex + 1
	end

	--[[
	Winning Effect: 
	1. Winning card beams the board
	2. For each board piece, create a clone
	3. Piece out the equation quickly
	]]
	local winSequenceTable = {}
	local winSequenceFolderConnection = CurrentGameInfo.ancestorModel.WinSequenceFolder.ChildAdded:Connect(function()
		local iterator = 0
		local gapSize = 4
		for _, v in pairs(winSequenceTable) do
			local newPosition = GameUtilities.Get_Starting_Position(CurrentGameInfo._originalOriginPosition + GameInfo.WinningSequenceOffsetGoal,
			 gapSize, iterator, #CurrentGameInfo.ancestorModel.WinSequenceFolder:GetChildren(), CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v, GameInfo.WinningSequenceTweenInfo, {Position = newPosition})
			positionTween:Play()

			iterator = iterator + 1
		end
	end)

	CameraFollowRE:FireClient(player, winningCard._cardObject.Base_Card)
	winningCard._cardObject.Base_Card.Sounds.Electric_Sound_Loop:Play()

	local boardCardCloneTable = {}
	local beamTable = {}
	local attachment0Table = {}

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "Attachment1"
	attachment1.Parent = winningCard._cardObject.PrimaryPart
	for _, v in pairs(CurrentGameInfo.ancestorModel.BoardCards:GetChildren()) do
		local boardCardClone = v:Clone()
		boardCardClone.Transparency = 1
		boardCardClone.Parent = CurrentGameInfo.ancestorModel.Cleanup
		table.insert(boardCardCloneTable, boardCardClone)

		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "Attachment0"
		attachment0.Parent = boardCardClone

		local newBeam = Instance.new("Beam")
		newBeam.Attachment0 = attachment0
		newBeam.Attachment1 = attachment1
		newBeam.FaceCamera = true
		newBeam.Texture = GameInfo.WinningCardBeamTexture
		newBeam.Width0 = 6
		newBeam.Width1 = 6
		newBeam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		}
		newBeam.Parent = attachment0

		local boardCloneTween = TweenService:Create(boardCardClone, GameInfo.BoardCardTweenInfo, {Position = boardCardClone.Position + Vector3.new(-1,0,0), 
			Transparency = .5, Orientation = Vector3.new(0, CurrentGameInfo._orientationDegrees, 0)})
		boardCloneTween:Play()
	end

	local winningCardTween = TweenService:Create(winningCard._cardObject.PrimaryPart, GameInfo.WinningCardTweenInfo, 
		{Position = winningCard._cardObject.PrimaryPart.Position + GameInfo.WinningCardOffsetGoal})
	
	winningCardTween.Completed:Connect(function()
		CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
		CameraSetFOVRE:FireClient(player, GameInfo.FOVWinning, GameInfo.FOVSetTime)
		for i, v in ipairs(winningSequence) do
			-- 1. create a new part based on item in sequence, 2. move part to location 3. add to folder 4. once its tween is over, play some effect
			if type(winningSequence[i]) ~= "number" then
				local newPart = GameInfo.LookUpTable[winningSequence[i]]:Clone()
				newPart.Position = CurrentGameInfo.ancestorModel.Center.Position
				GameUtilities.Set_Orientation(newPart, CurrentGameInfo._orientationDegrees + 180)
				table.insert(winSequenceTable, newPart)
				newPart.Parent = CurrentGameInfo.ancestorModel.WinSequenceFolder

				newPart.Sounds.Swoosh_1:Play()
			else
				-- find the corresponding value in the boardClones, add it to the winSequenceTable + parent to folder, remove from the boardClones
				for _, v in pairs(boardCardCloneTable) do
					if v:GetAttribute("value") == winningSequence[i] then
						table.insert(winSequenceTable, v)
						v.Parent = CurrentGameInfo.ancestorModel.WinSequenceFolder
						table.remove(boardCardCloneTable, table.find(boardCardCloneTable, v))
						break
					end
				end
			end
			wait(.1) --TODO: Config
		end
		winSequenceFolderConnection:Disconnect()

		wait(2) --TODO: Config

		for _, v in pairs(winSequenceTable) do
			local squeezeTween = TweenService:Create(v, GameInfo.WinningSequenceSqueezeTweenInfo, {Size = Vector3.new(.5, .5, .5), Transparency = 1})
			local squeezeTweenConnection
			squeezeTweenConnection = squeezeTween.Completed:Connect(function()
				v:Destroy()
				squeezeTweenConnection:Disconnect()

				local energyBall = Energyball:Clone()
				energyBall.Position = v.Position
				energyBall.Parent = CurrentGameInfo.ancestorModel.Cleanup
				local energyBallTween = TweenService:Create(energyBall, GameInfo.WinningSequenceEnergyBallTweenInfo, {Position = CurrentGameInfo.ancestorModel.Center.Position})
				energyBallTween.Completed:Connect(function()
					energyBall:Destroy()
					if CurrentGameInfo._winSequencePlaying == true then
						finishedWinSequenceEvent:Fire()
						CurrentGameInfo._winSequencePlaying = false
					end
				end)
				energyBall.Sounds.Air_Woosh_Long.Volume = 0.05
				energyBall.Sounds.Air_Woosh_Long:Play()
				energyBallTween:Play()
			end)
			squeezeTween:Play()
		end
	end)
	winningCardTween:Play()
end

GameUtilities.Win_Sequence_NPC = function(Player_Game_Cards, NPC_Game_Cards, CurrentGameInfo, finishedWinSequenceEvent)
	DefeatEventRE:FireClient(CurrentGameInfo.currentPlayer)

	-- Move Camera back to default position
	CameraMoveToRE:FireClient(CurrentGameInfo.currentPlayer, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	-- TODO: Add some Camera Shake
	-- Explode the player's cards for losing
	if Player_Game_Cards then
		-- clean up and destroy cards and operators if any
		for _, v in pairs(Player_Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject.Base_Card.ClickDetector:Destroy()

			local explosionCore = Explosion_Core:Clone()
			explosionCore.Parent = CurrentGameInfo.ancestorModel.Cleanup
			Debris:AddItem(explosionCore, 2)
			explosionCore.Position = v._cardObject.Base_Card.Position
			explosionCore.Dirt:Emit(50)
			explosionCore.Explosion_Random:Emit(50)
			explosionCore.Heat:Emit(50)
			explosionCore.Shockwave:Emit(50)
			explosionCore.Sounds.Explosion_sound_effect:Play()
			v._cardObject:Destroy()
		end
		table.clear(Player_Game_Cards)
		Player_Game_Cards = nil -- allow cleanup
	end

	local winningCard = NPC_Game_Cards[1]
	local winningCardTable = winningCard._cardTable
	local winningSequence = {}
	local winningString = CardObject.getSequence(winningCardTable)
	print(winningString)
	local startIndex = 1
	while startIndex <= string.len(winningString) do
		local character = string.sub(winningString, startIndex, startIndex)
		if tonumber(character) ~= nil then
			local startOfNumber = startIndex
			local endOfNumber = startIndex
			while tonumber(string.sub(winningString, startIndex + 1, startIndex + 1)) ~= nil do
				startIndex = startIndex + 1
				endOfNumber = startIndex
			end
			table.insert(winningSequence, tonumber(string.sub(winningString, startOfNumber, endOfNumber)))
		else
			table.insert(winningSequence, character)
		end
		startIndex = startIndex + 1
	end

	local winSequenceTable = {}
	local winSequenceFolderConnection = CurrentGameInfo.ancestorModel.AI_WinSequenceFolder.ChildAdded:Connect(function()
		local iterator = 0
		local gapSize = 4
		for _, v in pairs(winSequenceTable) do
			local newPosition = GameUtilities.Get_Starting_Position(CurrentGameInfo._npcOriginalOriginPosition + GameInfo.WinningSequenceOffsetGoal,
			 gapSize, iterator, #CurrentGameInfo.ancestorModel.AI_WinSequenceFolder:GetChildren(), CurrentGameInfo._npcOrientation)

			local positionTween = TweenService:Create(v, GameInfo.WinningSequenceTweenInfo, {Position = newPosition})
			positionTween:Play()

			iterator = iterator + 1
		end
	end)
	
	winningCard._cardObject.Base_Card.Sounds.Electric_Sound_Loop:Play()

	local boardCardCloneTable = {}
	local beamTable = {}
	local attachment0Table = {}

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "Attachment1"
	attachment1.Parent = winningCard._cardObject.PrimaryPart
	for _, v in pairs(CurrentGameInfo.ancestorModel.BoardCards:GetChildren()) do
		local boardCardClone = v:Clone()
		boardCardClone.Transparency = 1
		boardCardClone.Parent = CurrentGameInfo.ancestorModel.Cleanup
		table.insert(boardCardCloneTable, boardCardClone)

		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "Attachment0"
		attachment0.Parent = boardCardClone

		local newBeam = Instance.new("Beam")
		newBeam.Attachment0 = attachment0
		newBeam.Attachment1 = attachment1
		newBeam.FaceCamera = true
		newBeam.Texture = GameInfo.WinningCardBeamTexture
		newBeam.Width0 = 6
		newBeam.Width1 = 6
		newBeam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		}
		newBeam.Parent = attachment0

		local boardCloneTween = TweenService:Create(boardCardClone, GameInfo.BoardCardTweenInfo, {Position = boardCardClone.Position + Vector3.new(-1,0,0), 
			Transparency = .5, Orientation = Vector3.new(0, CurrentGameInfo._npcOrientationDegrees, 0)})
		boardCloneTween:Play()
	end

	local winningCardTween = TweenService:Create(winningCard._cardObject.PrimaryPart, GameInfo.WinningCardTweenInfo, 
		{Position = winningCard._cardObject.PrimaryPart.Position + GameInfo.WinningCardOffsetGoal})
	
	winningCardTween.Completed:Connect(function()
		for i, v in ipairs(winningSequence) do
			-- 1. create a new part based on item in sequence, 2. move part to location 3. add to folder 4. once its tween is over, play some effect
			if type(winningSequence[i]) ~= "number" then
				local newPart = GameInfo.LookUpTable[winningSequence[i]]:Clone()
				newPart.Position = CurrentGameInfo.ancestorModel.Center.Position
				GameUtilities.Set_Orientation(newPart, CurrentGameInfo._npcOrientationDegrees + 180)
				table.insert(winSequenceTable, newPart)
				newPart.Parent = CurrentGameInfo.ancestorModel.AI_WinSequenceFolder

				newPart.Sounds.Swoosh_1:Play()
			else
				print("Number")
				-- find the corresponding value in the boardClones, add it to the winSequenceTable + parent to folder, remove from the boardClones
				for _, v in pairs(boardCardCloneTable) do
					if v:GetAttribute("value") == winningSequence[i] then
						table.insert(winSequenceTable, v)
						v.Parent = CurrentGameInfo.ancestorModel.AI_WinSequenceFolder
						table.remove(boardCardCloneTable, table.find(boardCardCloneTable, v))
						break
					end
				end
			end
			wait(.1) --TODO: Config
		end
		winSequenceFolderConnection:Disconnect()

		wait(2) --TODO: Config

		for _, v in pairs(winSequenceTable) do
			local squeezeTween = TweenService:Create(v, GameInfo.WinningSequenceSqueezeTweenInfo, {Size = Vector3.new(.5, .5, .5), Transparency = 1})
			local squeezeTweenConnection
			squeezeTweenConnection = squeezeTween.Completed:Connect(function()
				v:Destroy()
				squeezeTweenConnection:Disconnect()

				local energyBall = Energyball:Clone()
				energyBall.Position = v.Position
				energyBall.Parent = CurrentGameInfo.ancestorModel.Cleanup
				local energyBallTween = TweenService:Create(energyBall, GameInfo.WinningSequenceEnergyBallTweenInfo, {Position = CurrentGameInfo.ancestorModel.Center.Position})
				energyBallTween.Completed:Connect(function()
					energyBall:Destroy()
					if CurrentGameInfo._winSequencePlaying == true then
						finishedWinSequenceEvent:Fire()
						CurrentGameInfo._winSequencePlaying = false
					end
				end)
				energyBall.Sounds.Air_Woosh_Long:Play()
				energyBallTween:Play()
			end)
			squeezeTween:Play()
		end
	end)
	winningCardTween:Play()
end

GameUtilities.Win_Sequence_Player = function(Player_Game_Cards, NPC_Game_Cards, CurrentGameInfo, finishedWinSequenceEvent, player)
	VictoryEventRE:FireClient(player)
	-- Explode the opponent's cards for losing
	if NPC_Game_Cards then
		-- clean up and destroy cards and operators if any
		for _, v in pairs(NPC_Game_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject.Base_Card.ClickDetector:Destroy()

			local explosionCore = Explosion_Core:Clone()
			explosionCore.Parent = CurrentGameInfo.ancestorModel.Cleanup
			Debris:AddItem(explosionCore, 2)
			explosionCore.Position = v._cardObject.Base_Card.Position
			explosionCore.Dirt:Emit(50)
			explosionCore.Explosion_Random:Emit(50)
			explosionCore.Heat:Emit(50)
			explosionCore.Shockwave:Emit(50)
			explosionCore.Sounds.Explosion_sound_effect:Play()
			v._cardObject:Destroy()
		end
		table.clear(NPC_Game_Cards)
		NPC_Game_Cards = nil -- allow cleanup
	end

	local winningCard = Player_Game_Cards[1]
	local winningCardTable = winningCard._cardTable
	local winningSequence = {}
	local winningString = CardObject.getSequence(winningCardTable)
	print(winningString)

	-- GameStats Changes
	GameUtilities.IncrementStats(CurrentGameInfo._difficulty, winningString, player, CurrentGameInfo._opponentName)

	local startIndex = 1
	while startIndex <= string.len(winningString) do
		local character = string.sub(winningString, startIndex, startIndex)
		if tonumber(character) ~= nil then
			local startOfNumber = startIndex
			local endOfNumber = startIndex
			while tonumber(string.sub(winningString, startIndex + 1, startIndex + 1)) ~= nil do
				startIndex = startIndex + 1
				endOfNumber = startIndex
			end
			table.insert(winningSequence, tonumber(string.sub(winningString, startOfNumber, endOfNumber)))
		else
			table.insert(winningSequence, character)
		end
		startIndex = startIndex + 1
	end

	local winSequenceTable = {}
	local winSequenceFolderConnection = CurrentGameInfo.ancestorModel.WinSequenceFolder.ChildAdded:Connect(function()
		local iterator = 0
		local gapSize = 4
		for _, v in pairs(winSequenceTable) do
			local newPosition = GameUtilities.Get_Starting_Position(CurrentGameInfo._originalOriginPosition + GameInfo.WinningSequenceOffsetGoal,
			 gapSize, iterator, #CurrentGameInfo.ancestorModel.WinSequenceFolder:GetChildren(), CurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v, GameInfo.WinningSequenceTweenInfo, {Position = newPosition})
			positionTween:Play()

			iterator = iterator + 1
		end
	end)

	CameraFollowRE:FireClient(player, winningCard._cardObject.Base_Card)
	winningCard._cardObject.Base_Card.Sounds.Electric_Sound_Loop:Play()

	local boardCardCloneTable = {}

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "Attachment1"
	attachment1.Parent = winningCard._cardObject.PrimaryPart
	for _, v in pairs(CurrentGameInfo.ancestorModel.BoardCards:GetChildren()) do
		local boardCardClone = v:Clone()
		boardCardClone.Transparency = 1
		boardCardClone.Parent = CurrentGameInfo.ancestorModel.Cleanup
		table.insert(boardCardCloneTable, boardCardClone)

		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "Attachment0"
		attachment0.Parent = boardCardClone

		local newBeam = Instance.new("Beam")
		newBeam.Attachment0 = attachment0
		newBeam.Attachment1 = attachment1
		newBeam.FaceCamera = true
		newBeam.Texture = GameInfo.WinningCardBeamTexture
		newBeam.Width0 = 6
		newBeam.Width1 = 6
		newBeam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		}
		newBeam.Parent = attachment0

		local boardCloneTween = TweenService:Create(boardCardClone, GameInfo.BoardCardTweenInfo, {Position = boardCardClone.Position + Vector3.new(-1,0,0), 
			Transparency = .5, Orientation = Vector3.new(0, CurrentGameInfo._orientationDegrees, 0)})
		boardCloneTween:Play()
	end

	local winningCardTween = TweenService:Create(winningCard._cardObject.PrimaryPart, GameInfo.WinningCardTweenInfo, 
		{Position = winningCard._cardObject.PrimaryPart.Position + GameInfo.WinningCardOffsetGoal})
	
	winningCardTween.Completed:Connect(function()
		CameraMoveToRE:FireClient(player, CurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
		CameraSetFOVRE:FireClient(player, GameInfo.FOVWinning, GameInfo.FOVSetTime)
		for i, v in ipairs(winningSequence) do
			-- 1. create a new part based on item in sequence, 2. move part to location 3. add to folder 4. once its tween is over, play some effect
			if type(winningSequence[i]) ~= "number" then
				local newPart = GameInfo.LookUpTable[winningSequence[i]]:Clone()
				newPart.Position = CurrentGameInfo.ancestorModel.Center.Position
				GameUtilities.Set_Orientation(newPart, CurrentGameInfo._orientationDegrees + 180)
				table.insert(winSequenceTable, newPart)
				newPart.Parent = CurrentGameInfo.ancestorModel.WinSequenceFolder

				newPart.Sounds.Swoosh_1:Play()
			else
				-- find the corresponding value in the boardClones, add it to the winSequenceTable + parent to folder, remove from the boardClones
				for _, v in pairs(boardCardCloneTable) do
					if v:GetAttribute("value") == winningSequence[i] then
						table.insert(winSequenceTable, v)
						v.Parent = CurrentGameInfo.ancestorModel.WinSequenceFolder
						table.remove(boardCardCloneTable, table.find(boardCardCloneTable, v))
						break
					end
				end
			end
			wait(.1) --TODO: Config
		end
		winSequenceFolderConnection:Disconnect()

		wait(2) --TODO: Config

		for _, v in pairs(winSequenceTable) do
			local squeezeTween = TweenService:Create(v, GameInfo.WinningSequenceSqueezeTweenInfo, {Size = Vector3.new(.5, .5, .5), Transparency = 1})
			local squeezeTweenConnection
			squeezeTweenConnection = squeezeTween.Completed:Connect(function()
				v:Destroy()
				squeezeTweenConnection:Disconnect()

				local energyBall = Energyball:Clone()
				energyBall.Position = v.Position
				energyBall.Parent = CurrentGameInfo.ancestorModel.Cleanup
				local energyBallTween = TweenService:Create(energyBall, GameInfo.WinningSequenceEnergyBallTweenInfo, {Position = CurrentGameInfo.ancestorModel.Center.Position})
				energyBallTween.Completed:Connect(function()
					energyBall:Destroy()
					if CurrentGameInfo._winSequencePlaying == true then
						finishedWinSequenceEvent:Fire()
						CurrentGameInfo._winSequencePlaying = false
					end
				end)
				energyBall.Sounds.Air_Woosh_Long:Play()
				energyBallTween:Play()
			end)
			squeezeTween:Play()
		end
	end)
	winningCardTween:Play()

	-- add title for beating tommy two decks
	if CurrentGameInfo._opponentName == "Tommy Two Decks" then
		TitleModule.AddTitleToUser(CurrentGameInfo.currentPlayer, 3)
	end
end

GameUtilities.Select_Card = function(card, model, NPC_Game_Cards, CurrentGameInfo)
	local operatorIsSelected = false
	local cardSelected = false
	local otherCard
	-- check if another card has already been selected
	for _, v in pairs(NPC_Game_Cards) do
		if v._selected then
			cardSelected = true
			break
		end
	end
	-- check if an operator has already been selected
	for _, v in pairs(NPC_Game_Cards) do
		if v._operatorSetObject and v._operatorSetObject._operatorSelectedName ~= nil then
			operatorIsSelected = true
			otherCard = v
			break
		end
	end

	if cardSelected and operatorIsSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (combine)
		if card._selected then
			card._selected = false
			local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, GameInfo.SelectTweenInfo, {Position = card._startingPosition})
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
			GameUtilities.Set_Orientation(combinedCardObject.PrimaryPart, CurrentGameInfo._npcOrientationDegrees)

			GameUtilities.Hide_Operators(otherCard)
			
			--remove cards from game_cards and folder, then add to game_cards and lastly the folder
			local indexOfCard = table.find(NPC_Game_Cards, card)
			local indexOfOtherCard = table.find(NPC_Game_Cards, otherCard)
			local newIndex = math.floor((indexOfCard + indexOfOtherCard) / 2)

			if indexOfCard > indexOfOtherCard then -- remove in correct order
				table.remove(NPC_Game_Cards, indexOfCard)
				table.remove(NPC_Game_Cards, indexOfOtherCard)
			else
				table.remove(NPC_Game_Cards, indexOfOtherCard)
				table.remove(NPC_Game_Cards, indexOfCard)
			end
			table.insert(NPC_Game_Cards, newIndex, combinedCard)
			
			
			-- disable click detectors while the combine is occuring
			local cardBase = card._cardObject.Base_Card
			local otherCardBase = otherCard._cardObject.Base_Card

			--[[ Combine effects (sphereical coordinates)
			1. Get midpoint of two cards
			1.5. Combine_Core in the midpoint
			2. Transform cards into energy ball effects
			]]
			local targetCFrame = cardBase.CFrame:Lerp(otherCardBase.CFrame, .5) + Vector3.new(0,5,0)

			local combineCore = Combine_Core:Clone()
			combineCore.Position = targetCFrame.Position
			combineCore.Parent = game.Workspace
			Debris:AddItem(combineCore, 5)
			
			local energyBall1 = Energyball:Clone()
			energyBall1.Position = card._cardObject.PrimaryPart.Position
			energyBall1.Parent = game.Workspace

			local energyBall2 = Energyball:Clone()
			energyBall2.Position = otherCard._cardObject.PrimaryPart.Position
			energyBall2.Parent = game.Workspace

			local basePhi = SphereUtilities.getXY(cardBase.Position, targetCFrame.Position)
			local baseTheta = SphereUtilities.getXZ(cardBase.Position, targetCFrame.Position)
			local baseDistance = SphereUtilities.getDistance(cardBase.Position, targetCFrame.Position)
			local baseDistanceValue = Instance.new("NumberValue")
			baseDistanceValue.Value = baseDistance
			baseDistanceValue.Parent = energyBall1

			local otherPhi = SphereUtilities.getXY(otherCardBase.Position, targetCFrame.Position)
			local otherTheta = SphereUtilities.getXZ(otherCardBase.Position, targetCFrame.Position)
			local otherDistance = SphereUtilities.getDistance(otherCardBase.Position, targetCFrame.Position)
			local otherDistanceValue = Instance.new("NumberValue")
			otherDistanceValue.Value = otherDistance
			baseDistanceValue.Parent = energyBall2

			energyBall1.Position = SphereUtilities.sphereToRect2(baseDistance, basePhi, baseTheta, targetCFrame.Position)
			energyBall2.Position = SphereUtilities.sphereToRect2(otherDistance, otherPhi, otherTheta, targetCFrame.Position)

			-- effects
			local combineTweenInfo = TweenInfo.new(1)
			local squeezeTweenInfo = TweenInfo.new(.5)
			-- cards are morphed into balls, tween orientation + transparency + size
			local squeezeCardTween = TweenService:Create(cardBase, squeezeTweenInfo, 
				{Orientation = cardBase.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60)),
				Transparency = .8, Size = Vector3.new(.1, .5, .3)})
			local squeezeOtherCardTween = TweenService:Create(otherCardBase, squeezeTweenInfo, 
				{Orientation = cardBase.Orientation + Vector3.new(math.random(-60,60),math.random(-60,60),math.random(-60,60)),
				Transparency = .8, Size = Vector3.new(.1, .5, .3)})

			squeezeOtherCardTween.Completed:Connect(function()
				card._cardObject:Destroy()
				otherCard._cardObject:Destroy()
				
				local phiIncrement = math.random(5,15) * .01
				local baseCounter = 0
				local otherCounter = 0
				local baseDistanceValueTween = TweenService:Create(baseDistanceValue, combineTweenInfo, {Value = 0})
				baseDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
					energyBall1.Position = SphereUtilities.sphereToRect2(baseDistanceValue.Value, basePhi + (phiIncrement * baseCounter), baseTheta, targetCFrame.Position)
					baseCounter = baseCounter + 1
				end)
				local otherDistanceValueTween = TweenService:Create(otherDistanceValue, combineTweenInfo, {Value = 0})
				otherDistanceValue:GetPropertyChangedSignal("Value"):Connect(function()
					energyBall2.Position = SphereUtilities.sphereToRect2(otherDistanceValue.Value, otherPhi + (phiIncrement * otherCounter), otherTheta, targetCFrame.Position)
					otherCounter = otherCounter + 1
				end)
				baseDistanceValueTween.Completed:Connect(function()
					-- explosion and destroy
					for _, v in pairs(combineCore.Attachment:GetChildren()) do
						v.Enabled = false
					end
					combineCore.Sparks.Enabled = false
					combineCore.Explosion_Random:Emit(50)
					combineCore.Stars:Emit(50)
					energyBall1:Destroy()
					energyBall2:Destroy()
					
					combinedCard:UpdateGUI()
					combinedCardObject.PrimaryPart.Position = targetCFrame.Position 
					combinedCardObject.Parent = model.AI_CardFolder
				end)
				baseDistanceValueTween:Play()
				otherDistanceValueTween:Play()
			end)
			squeezeCardTween:Play()
			squeezeOtherCardTween:Play()
			return true -- returns true if combined
		end
	elseif cardSelected then -- (2) 1: selecting self (deselect self), 2: selecting another (select another)
		if card._selected then
			card._selected = false
			local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, GameInfo.SelectTweenInfo, {Position = card._startingPosition})
			hoverTween:Play()
			GameUtilities.Hide_Operators(card)
		else
			for _, v in pairs(NPC_Game_Cards) do
				if v ~= card then
					v._selected = false
					local hoverTween = TweenService:Create(v._cardObject.PrimaryPart, GameInfo.SelectTweenInfo, {Position = v._startingPosition})
					hoverTween:Play()
					GameUtilities.Hide_Operators(v)
				end
			end
			card._selected = true
			local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, GameInfo.SelectTweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
			hoverTween:Play()
		end
	else -- select a card
		card._selected = true
		local hoverTween = TweenService:Create(card._cardObject.PrimaryPart, GameInfo.SelectTweenInfo, {Position = card._startingPosition + Vector3.new(0,3,0)})
		hoverTween:Play()
	end
end

GameUtilities.NPC_Reveal_Operators = function(newCard, CurrentGameInfo)
	-- Create new operator set object
	local newOperatorSetObject = OperatorSetObject.new()
	-- clone operator set
	newOperatorSetObject._operatorSet = Operator_Set_Model:Clone()

	-- set the card's operators to the new object
	newCard._operatorSetObject = newOperatorSetObject

	local operatorSet = newOperatorSetObject._operatorSet -- label for ease of access
	operatorSet.Parent = game.Workspace -- TODO: set to somewhere else
	local offset = Vector3.new(0,5.5,0)
	operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset)
		* CFrame.Angles(0, CurrentGameInfo._npcOrientation + math.pi, 0))
	newOperatorSetObject._cardPositionChangedSignal = newCard._cardObject.PrimaryPart:GetPropertyChangedSignal("Position"):Connect(function()
		operatorSet:SetPrimaryPartCFrame(CFrame.new(newCard._cardObject.PrimaryPart.Position + offset) 
		* CFrame.Angles(0, CurrentGameInfo._npcOrientation + math.pi, 0))
	end)
end

GameUtilities.NPC_Action_Initialization = function(sequence, NPC_Game_Cards, CurrentGameInfo)
	--[[
		0. Pull a solution to current game

		1. Generate a sequence of moves
		- Select
		- Select Operator
		- Combine
		3 sets of that and we are left with one card

		2. Execute moves one at a time until done
	]]
	-- 0: As of now, solutions are simply provided
	for i, _ in ipairs(sequence) do
		-- put delay
		wait(4)
		if CurrentGameInfo._winSequencePlaying then
			return
		end
		print(sequence[i])
		if type(sequence[i]) == "number" then
			-- find and select the number
			for _, v in pairs (NPC_Game_Cards) do
				if sequence[i] == CardObject.calculateValue(v._cardTable) and v._selected == false then -- found number
					-- select card
					local combined = GameUtilities.Select_Card(v, CurrentGameInfo.ancestorModel, NPC_Game_Cards, CurrentGameInfo)
					-- reveal operator
					if not combined then
						GameUtilities.NPC_Reveal_Operators(v, CurrentGameInfo)
					end
					break
				end
			end
			
		else
			-- select operator 1. find card selected and get its operator set
			for _, v in pairs(NPC_Game_Cards) do
				if v._operatorSetObject then
					print("Selected operator")
					v._operatorSetObject:SelectSpecific(GameInfo.OperatorNames[sequence[i]])
				end
			end
		end
	end
	-- win
end

GameUtilities.IncrementStats = function(difficulty, solution, player, npcBeaten)
	-- Increment XP and currency by some amount based on the difficulty, also increment the number of wins
	if npcBeaten then
		GameStatsUtilities.incrementXP(player, GameInfo.NPCXPTable[difficulty])
		GameStatsUtilities.incrementCurrency(player, GameInfo.NPCCurrencyTable[difficulty])
		GameStatsUtilities.incrementGame24Wins(player)
		GameStatsUtilities.saveLastSolution(player, solution) -- save win solution
		GameStatsUtilities.newGame24NPCDefeated(player, npcBeaten)
	else
		GameStatsUtilities.incrementXP(player, GameInfo.SinglePlayerXPTable[difficulty])
		GameStatsUtilities.incrementCurrency(player, GameInfo.SinglePlayerCurrencyTable[difficulty])
		GameStatsUtilities.incrementGame24Wins(player)
		GameStatsUtilities.saveLastSolution(player, solution) -- save win solution
	end
end

GameUtilities.Win_Sequence_Competitive = function(winningPlayerCurrentGameInfo, losingPlayerCurrentGameInfo, winningPlayerGame_Cards, losingPlayerGame_Cards, finishedWinSequenceEvent)
	------ Victory and Defeat GUI for each player ------
	VictoryEventRE:FireClient(winningPlayerCurrentGameInfo.currentPlayer)
	DefeatEventRE:FireClient(losingPlayerCurrentGameInfo.currentPlayer)

	------ Losing Player Loses Their Cards and Their Camera is Reset
	CameraMoveToRE:FireClient(losingPlayerCurrentGameInfo.currentPlayer, losingPlayerCurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
	if losingPlayerGame_Cards then
		for _, v in pairs(losingPlayerGame_Cards) do
			GameUtilities.Hide_Operators(v)
			v._cardObject.Base_Card.ClickDetector:Destroy()

			local explosionCore = Explosion_Core:Clone()
			explosionCore.Parent = losingPlayerCurrentGameInfo.ancestorModel.Cleanup
			Debris:AddItem(explosionCore, 2)
			explosionCore.Position = v._cardObject.Base_Card.Position
			explosionCore.Dirt:Emit(50)
			explosionCore.Explosion_Random:Emit(50)
			explosionCore.Heat:Emit(50)
			explosionCore.Shockwave:Emit(50)
			explosionCore.Sounds.Explosion_sound_effect:Play()
			v._cardObject:Destroy()
		end
		table.clear(losingPlayerGame_Cards)
		losingPlayerGame_Cards = nil -- allow cleanup
	end

	------ Get equation from last card ------
	local winningCard = winningPlayerGame_Cards[1]
	local winningCardTable = winningCard._cardTable
	local winningSequence = {}
	local winningString = CardObject.getSequence(winningCardTable)
	--print(winningString)

	------ GameStats Changes ------ TODO: change to dynamic with difficulty, by default all are easy
	GameUtilities.IncrementStats("easy", winningString, winningPlayerCurrentGameInfo.currentPlayer, nil)

	------ Construct winning sequence (list of chars of winnningString) ------
	local startIndex = 1
	while startIndex <= string.len(winningString) do
		local character = string.sub(winningString, startIndex, startIndex)
		if tonumber(character) ~= nil then
			local startOfNumber = startIndex
			local endOfNumber = startIndex
			while tonumber(string.sub(winningString, startIndex + 1, startIndex + 1)) ~= nil do
				startIndex = startIndex + 1
				endOfNumber = startIndex
			end
			table.insert(winningSequence, tonumber(string.sub(winningString, startOfNumber, endOfNumber)))
		else
			table.insert(winningSequence, character)
		end
		startIndex = startIndex + 1
	end

	------ Setup WinSequenceFolder Connection To Reposition Objects Upon Insertion ------
	local winSequenceTable = {}
	local winSequenceFolderConnection = winningPlayerCurrentGameInfo._winSequenceFolder.ChildAdded:Connect(function()
		local iterator = 0
		for _, v in pairs(winSequenceTable) do
			local newPosition = GameUtilities.Get_Starting_Position(winningPlayerCurrentGameInfo._originalOriginPosition + GameInfo.WinningSequenceOffsetGoal,
			 GameInfo.GAP_SIZE, iterator, #winningPlayerCurrentGameInfo._winSequenceFolder:GetChildren(), winningPlayerCurrentGameInfo._orientation)

			local positionTween = TweenService:Create(v, GameInfo.WinningSequenceTweenInfo, {Position = newPosition})
			positionTween:Play()

			iterator = iterator + 1
		end
	end)

	------ Camera Set To Follow the Winning Card + Sound Effect Play ------
	CameraFollowRE:FireClient(winningPlayerCurrentGameInfo.currentPlayer, winningCard._cardObject.Base_Card)
	winningCard._cardObject.Base_Card.Sounds.Electric_Sound_Loop:Play()

	------ Setup Beam to Board Cards Effect + Board Card Clone, Turn and Move Effect ------
	local boardCardCloneTable = {}
	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "Attachment1"
	attachment1.Parent = winningCard._cardObject.PrimaryPart
	for _, v in pairs(winningPlayerCurrentGameInfo.ancestorModel.BoardCards:GetChildren()) do
		local boardCardClone = v:Clone()
		boardCardClone.Transparency = 1
		boardCardClone.Parent = winningPlayerCurrentGameInfo.ancestorModel.Cleanup
		table.insert(boardCardCloneTable, boardCardClone)

		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "Attachment0"
		attachment0.Parent = boardCardClone

		local newBeam = Instance.new("Beam")
		newBeam.Attachment0 = attachment0
		newBeam.Attachment1 = attachment1
		newBeam.FaceCamera = true
		newBeam.Texture = GameInfo.WinningCardBeamTexture
		newBeam.Width0 = 6
		newBeam.Width1 = 6
		newBeam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		}
		newBeam.Parent = attachment0

		local boardCloneTween = TweenService:Create(boardCardClone, GameInfo.BoardCardTweenInfo, {Position = boardCardClone.Position + Vector3.new(-1,0,0), 
			Transparency = .5, Orientation = Vector3.new(0, winningPlayerCurrentGameInfo._orientationDegrees, 0)})
		boardCloneTween:Play()
	end

	------ Setup Winning Card Flying Up Effect ------
	local winningCardTween = TweenService:Create(winningCard._cardObject.PrimaryPart, GameInfo.WinningCardTweenInfo, 
		{Position = winningCard._cardObject.PrimaryPart.Position + GameInfo.WinningCardOffsetGoal})
	
	winningCardTween.Completed:Connect(function()
		------ Camera Resets to Default and FOV increases ------
		CameraMoveToRE:FireClient(winningPlayerCurrentGameInfo.currentPlayer, winningPlayerCurrentGameInfo._defaultCameraCFrame, GameInfo.InitialCameraMoveTime)
		CameraSetFOVRE:FireClient(winningPlayerCurrentGameInfo.currentPlayer, GameInfo.FOVWinning, GameInfo.FOVSetTime)
		------ Win Sequence Part and Board Card Show Sequence Effect ------
		for i, v in ipairs(winningSequence) do
			if type(winningSequence[i]) ~= "number" then
				local newPart = GameInfo.LookUpTable[winningSequence[i]]:Clone()
				newPart.Position = winningPlayerCurrentGameInfo.ancestorModel.Center.Position
				GameUtilities.Set_Orientation(newPart, winningPlayerCurrentGameInfo._orientationDegrees + 180)
				table.insert(winSequenceTable, newPart)
				newPart.Parent = winningPlayerCurrentGameInfo._winSequenceFolder

				newPart.Sounds.Swoosh_1:Play()
			else
				for _, v in pairs(boardCardCloneTable) do
					if v:GetAttribute("value") == winningSequence[i] then
						table.insert(winSequenceTable, v)
						v.Parent = winningPlayerCurrentGameInfo._winSequenceFolder
						table.remove(boardCardCloneTable, table.find(boardCardCloneTable, v))
						break
					end
				end
			end
			wait(.1) --TODO: Config
		end
		winSequenceFolderConnection:Disconnect()

		wait(2) --TODO: Config

		------ Equation Flies Back to Board Effect ------
		for _, v in pairs(winSequenceTable) do
			local squeezeTween = TweenService:Create(v, GameInfo.WinningSequenceSqueezeTweenInfo, {Size = Vector3.new(.5, .5, .5), Transparency = 1})
			local squeezeTweenConnection
			squeezeTweenConnection = squeezeTween.Completed:Connect(function()
				v:Destroy()
				squeezeTweenConnection:Disconnect()

				local energyBall = Energyball:Clone()
				energyBall.Position = v.Position
				energyBall.Parent = winningPlayerCurrentGameInfo.ancestorModel.Cleanup
				local energyBallTween = TweenService:Create(energyBall, GameInfo.WinningSequenceEnergyBallTweenInfo, {Position = winningPlayerCurrentGameInfo.ancestorModel.Center.Position})
				energyBallTween.Completed:Connect(function()
					energyBall:Destroy()
					if winningPlayerCurrentGameInfo._winSequencePlaying == true then
						finishedWinSequenceEvent:Fire()
						winningPlayerCurrentGameInfo._winSequencePlaying = false
					end
				end)
				energyBall.Sounds.Air_Woosh_Long.Volume = 0.05
				energyBall.Sounds.Air_Woosh_Long:Play()
				energyBallTween:Play()
			end)
			squeezeTween:Play()
		end
	end)
	winningCardTween:Play()
end

return GameUtilities