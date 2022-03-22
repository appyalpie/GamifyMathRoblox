local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local IngredientGUI = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("IngredientFrame")
local Ingredient1QuantityDisplay = IngredientGUI:WaitForChild("Ingredient1Quantity")
local Ingredient2QuantityDisplay = IngredientGUI:WaitForChild("Ingredient2Quantity")
local Ingredient3QuantityDisplay = IngredientGUI:WaitForChild("Ingredient3Quantity")
 
local UpdatePlayerIngredientGUIEvent = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("UpdatePlayerIngredientGUIEvent")

local playerIngredientInventory = {}

local Populate = function()
    Ingredient1QuantityDisplay.Text = playerIngredientInventory["Ingredient1"]

    Ingredient2QuantityDisplay.Text = playerIngredientInventory["Ingredient2"]

    Ingredient3QuantityDisplay.Text = playerIngredientInventory["Ingredient3"]
end

local function onUpdatePlayerIngredientGUIEvent(playerIngredients)
    playerIngredientInventory = playerIngredients
    Populate()
end

UpdatePlayerIngredientGUIEvent.OnClientEvent:Connect(onUpdatePlayerIngredientGUIEvent)