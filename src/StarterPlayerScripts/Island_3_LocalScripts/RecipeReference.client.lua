local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AddTextToRecipeReferenceRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("AddTextToRecipeReferenceEvent")

--This will need to change with the heirarchy of the workspace
local textLabelOnPaper = Workspace.Island_3.Islands.PotionCreationTables.CombinationTable.Paper.SurfaceGuiPart.SurfaceGui.TextLabel

local function onAddTextToRecipeReferenceEvent(recipe)
    textLabelOnPaper.Text = recipe["Name"] .. " potion recipe: " ..
                            "\nIngredient1: " .. recipe["Ingredient1"] ..
                            "\nIngredient2: " .. recipe["Ingredient2"] ..
                            "\nIngredient3: " .. recipe["Ingredient3"]
end

AddTextToRecipeReferenceRE.OnClientEvent:Connect(onAddTextToRecipeReferenceEvent)
