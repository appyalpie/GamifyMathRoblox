local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local PotionPromptActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("PotionPromptActivatedEvent")
local CombinationButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombinationButtonActivatedEvent")
local MissingIngredientRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("MissingIngredientsEvent")
local InvalidRecipeRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("InvalidRecipeEvent")
local CombineMenuFinishedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombineMenuFinishedEvent")
local ExitButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ExitButtonActivatedEvent")
local Island3EnteredRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("Island3EnteredEvent")
local Island3ExitRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("Island3ExitEvent")
local PlayerExitCombinationServerRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("PlayerExitCombinationServerEvent")
local UpdatePlayerIngredientGUIRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("UpdatePlayerIngredientGUIEvent")

local IngredientGUI = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("IngredientFrame")

local Ingredient1QuantityDisplay = IngredientGUI.InlayFrame.Ingredient1Frame:WaitForChild("Ingredient1Quantity")
local Ingredient2QuantityDisplay = IngredientGUI.InlayFrame.Ingredient2Frame:WaitForChild("Ingredient2Quantity")
local Ingredient3QuantityDisplay = IngredientGUI.InlayFrame.Ingredient3Frame:WaitForChild("Ingredient3Quantity")

local IngredientFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("IngredientFrame")

local AddToPotionFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("AddToPotionFrame")
local AddIngredientsFrame = AddToPotionFrame:WaitForChild("InlayFrame"):WaitForChild("AddIngredientsFrame")

local CombineButton = AddToPotionFrame:WaitForChild("InlayFrame"):WaitForChild("CombineButton")
local ExitButton = AddToPotionFrame:WaitForChild("ExitButton")

local AddIngredient1SubFrame = AddIngredientsFrame:WaitForChild("Ingredient1Subframe")
local AddIngredient2SubFrame = AddIngredientsFrame:WaitForChild("Ingredient2Subframe")
local AddIngredient3SubFrame = AddIngredientsFrame:WaitForChild("Ingredient3Subframe")

local Ingredient1IncrementAmountToAdd = AddIngredient1SubFrame:WaitForChild("AddIngredient")
local Ingredient2IncrementAmountToAdd = AddIngredient2SubFrame:WaitForChild("AddIngredient")
local Ingredient3IncrementAmountToAdd = AddIngredient3SubFrame:WaitForChild("AddIngredient")

local Ingredient1DecrementAmountToAdd = AddIngredient1SubFrame:WaitForChild("SubtractIngredient")
local Ingredient2DecrementAmountToAdd = AddIngredient2SubFrame:WaitForChild("SubtractIngredient")
local Ingredient3DecrementAmountToAdd = AddIngredient3SubFrame:WaitForChild("SubtractIngredient")

local Ingredient1AmountToAddTextBox = AddIngredient1SubFrame:WaitForChild("IngredientAmount")
local Ingredient2AmountToAddTextBox = AddIngredient2SubFrame:WaitForChild("IngredientAmount")
local Ingredient3AmountToAddTextBox = AddIngredient3SubFrame:WaitForChild("IngredientAmount")

local combinationTableID

local playerIngredientInventory = {}


-- This is made in case of player death, and will reinitialize variables
local InitializeDeathConnect = function()
     ------ Connect Death Functionality ------
    game.Workspace:WaitForChild(Player.Name):WaitForChild("Humanoid").Died:Connect(function()
        local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
        local goalPosition = {}
        goalPosition.Position = UDim2.new(1,0,0.676,0)
        local tweenOut = TweenService:Create(IngredientFrame ,twinfo, goalPosition)
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            IngredientFrame.Visible = false
        end)
    end)
end



------ Plus button functionality on Combination Menu ------
Ingredient1IncrementAmountToAdd.Activated:Connect(function()
    Ingredient1AmountToAddTextBox.Text = tonumber(Ingredient1AmountToAddTextBox.Text) + 1
end)

Ingredient2IncrementAmountToAdd.Activated:Connect(function()
    Ingredient2AmountToAddTextBox.Text = tonumber(Ingredient2AmountToAddTextBox.Text) + 1
end)

Ingredient3IncrementAmountToAdd.Activated:Connect(function()
    Ingredient3AmountToAddTextBox.Text = tonumber(Ingredient3AmountToAddTextBox.Text) + 1
end)

------ Minus button functionality on Combination Menu ------
Ingredient1DecrementAmountToAdd.Activated:Connect(function()
    Ingredient1AmountToAddTextBox.Text = tonumber(Ingredient1AmountToAddTextBox.Text) - 1
end)

Ingredient2DecrementAmountToAdd.Activated:Connect(function()
    Ingredient2AmountToAddTextBox.Text = tonumber(Ingredient2AmountToAddTextBox.Text) - 1
end)

Ingredient3DecrementAmountToAdd.Activated:Connect(function()
    Ingredient3AmountToAddTextBox.Text = tonumber(Ingredient3AmountToAddTextBox.Text) - 1
end)

------ Text box validation - only positive numbers ------
Ingredient1AmountToAddTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newText = tonumber(Ingredient1AmountToAddTextBox.Text)
    if newText == nil or newText < 0 then
        newText = 0
    end
    Ingredient1AmountToAddTextBox.Text = newText;
end)

Ingredient2AmountToAddTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newText = tonumber(Ingredient2AmountToAddTextBox.Text)
    if newText == nil or newText < 0 then
        newText = 0
    end
    Ingredient2AmountToAddTextBox.Text = newText;
end)

Ingredient3AmountToAddTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newText = tonumber(Ingredient3AmountToAddTextBox.Text)
    if newText == nil or newText < 0 then
        newText = 0
    end
    Ingredient3AmountToAddTextBox.Text = newText;
end)

------ Combine! Button Functionality ------
CombineButton.Activated:Connect(function()
    -- Check to see if ingredients input is zero
    if tonumber(Ingredient1AmountToAddTextBox.Text) == 0 and
    tonumber(Ingredient2AmountToAddTextBox.Text) == 0 and
    tonumber(Ingredient3AmountToAddTextBox.Text) == 0 then
        CombineButton.Text = "Please put more than 0 Ingredients in!"
        CombineButton.TextColor3 = Color3.new(1,0,0)
        wait(2)
        CombineButton.Text = "Combine!"
        CombineButton.TextColor3 = Color3.new(0,0,0)
        return
    end

    local selectedIngredients = {
        Ingredient1 = tonumber(Ingredient1AmountToAddTextBox.Text), 
        Ingredient2 = tonumber(Ingredient2AmountToAddTextBox.Text), 
        Ingredient3 = tonumber(Ingredient3AmountToAddTextBox.Text)
    }
    CombinationButtonActivatedRE:FireServer(selectedIngredients, combinationTableID)
end)

------ Exit Button Functionality ------
ExitButton.Activated:Connect(function()
    ExitButtonActivatedRE:FireServer(combinationTableID)
end)

local Populate = function()
    Ingredient1QuantityDisplay.Text = playerIngredientInventory["Ingredient1"]

    Ingredient2QuantityDisplay.Text = playerIngredientInventory["Ingredient2"]

    Ingredient3QuantityDisplay.Text = playerIngredientInventory["Ingredient3"]
end

local function onUpdatePlayerIngredientGUIEvent(playerIngredients)
    playerIngredientInventory = playerIngredients
    Populate()
end

UpdatePlayerIngredientGUIRE.OnClientEvent:Connect(onUpdatePlayerIngredientGUIEvent)

------ Tween in the potion combination GUI ------
local function onPotionPromptActivatedEvent(currentCombinationTableID)
    combinationTableID = currentCombinationTableID
    AddToPotionFrame.Visible = true
    local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
    local goalPosition = {}
    goalPosition.Position = UDim2.new(0.794,0,0.204,0)
    local tweenIn = TweenService:Create(AddToPotionFrame ,twinfo, goalPosition)
    tweenIn:Play()
end

PotionPromptActivatedRE.OnClientEvent:Connect(onPotionPromptActivatedEvent)

------ Error handling for if you don't have enough ingredients ------
local function onMissingIngredientEvent()
    CombineButton.Text = "You don't have enough Ingredients for this combination!"
    CombineButton.TextColor3 = Color3.new(1,0,0)
    wait(4)
    CombineButton.Text = "Combine!"
    CombineButton.TextColor3 = Color3.new(0,0,0)
end

MissingIngredientRE.OnClientEvent:Connect(onMissingIngredientEvent)

------ Error handling if the combination entered is not a recipe ------
local function onInvalidRecipeEvent()
    CombineButton.Text = "Wrong recipe!"
    CombineButton.TextColor3 = Color3.new(1,0,0)
    wait(2)
    CombineButton.Text = "Combine!"
    CombineButton.TextColor3 = Color3.new(0,0,0)
end

InvalidRecipeRE.OnClientEvent:Connect(onInvalidRecipeEvent)

------ Called when the player is finished with the combine screen ------
local function onCombineMenuFinishedEvent()
    local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
    local goalPosition = {}
    goalPosition.Position = UDim2.new(1,0,0.204,0)
    local tweenOut = TweenService:Create(AddToPotionFrame ,twinfo, goalPosition)
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        AddToPotionFrame.Visible = false
        PlayerExitCombinationServerRE:FireServer(combinationTableID)
    end)
end

CombineMenuFinishedRE.OnClientEvent:Connect(onCombineMenuFinishedEvent)

------ Called when the player has entered island 3 ------
local function onIsland3EnteredEvent()
    InitializeDeathConnect()
    IngredientFrame.Visible = true
    local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
    local goalPosition = {}
    goalPosition.Position = UDim2.new(0.794,0,0.676,0)
    local tweenIn = TweenService:Create(IngredientFrame ,twinfo, goalPosition)
    tweenIn:Play()
end

Island3EnteredRE.OnClientEvent:Connect(onIsland3EnteredEvent)

------ Called when the player has entered a zone that's not island 3 ------
local function onIsland3ExitEvent()
    local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
    local goalPosition = {}
    goalPosition.Position = UDim2.new(1,0,0.676,0)
    local tweenOut = TweenService:Create(IngredientFrame ,twinfo, goalPosition)
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        IngredientFrame.Visible = false
    end)
end

Island3ExitRE.OnClientEvent:Connect(onIsland3ExitEvent)