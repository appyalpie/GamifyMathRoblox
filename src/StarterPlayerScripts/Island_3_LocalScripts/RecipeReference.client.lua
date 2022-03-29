local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AddTextToRecipeReferenceRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("AddTextToRecipeReferenceEvent")
local RecipeReferenceViewRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("RecipeReferenceViewEvent")
local ExitRecipeReferenceViewRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ExitRecipeReferenceViewEvent")

local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")

local allTables = Workspace.Island_3.Islands.PotionCreationTables:GetChildren()

local exitButton = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("RecipeViewExitButton")

local recipesOnPaper = {}

------- Add text to the recipe reference surface gui for this player when they unlock a recipe -------
local function onAddTextToRecipeReferenceEvent(recipe)
    for _,v in pairs(recipesOnPaper) do
        if v["Name"] == recipe["Name"] then
            return
        end
    end

    for _,combinationTable in pairs(allTables) do
        table.insert(recipesOnPaper, recipe)
        if combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.Text == "" then
            combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.Text = recipe["Name"] .. " recipe: " ..
                                    "\nMushrooms: " .. recipe["Ingredient1"] ..
                                    "\nBerries: " .. recipe["Ingredient2"] ..
                                    "\nHerbs: " .. recipe["Ingredient3"] ..
                                    "\nRatio: " .. recipe["Ingredient1"] .. ":" .. recipe["Ingredient2"] .. ":" .. recipe["Ingredient3"]
        else
            combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.Text = combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.Text .. "\n\n" ..
            recipe["Name"] .. " recipe: " ..
            "\nMushrooms: " .. recipe["Ingredient1"] ..
            "\nBerries: " .. recipe["Ingredient2"] ..
            "\nHerbs: " .. recipe["Ingredient3"] .. 
            "\nRatio: " .. recipe["Ingredient1"] .. ":" .. recipe["Ingredient2"] .. ":" .. recipe["Ingredient3"]
        end
    
        if combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.TextFits == false then
            combinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel.TextScaled = true
        end
    end
end

AddTextToRecipeReferenceRE.OnClientEvent:Connect(onAddTextToRecipeReferenceEvent)

------- activate the exit buttton when the recipe reference page is viewed -------
local function onRecipeReferenceViewEvent(player)
    wait(1)
    exitButton.Visible = true
end

RecipeReferenceViewRE.OnClientEvent:Connect(onRecipeReferenceViewEvent)

exitButton.Activated:Connect(function(player)
    ExitRecipeReferenceViewRE:FireServer(player)
    exitButton.Visible = false
end)