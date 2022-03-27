local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PotionPrompt = Workspace.Island_3.Islands.PotionCreationTables.CombinationTable.Beaker.Beaker.PromptAttachment.ProximityPrompt
local RecipeReferencePrompt = Workspace.Island_3.Islands.PotionCreationTables.CombinationTable.PaperHolder.PromptAttachment.ProximityPrompt
local PotionCreation = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionCreation"))
local RecipeReference = require(ServerScriptService.Island_3_Scripts.RecipeReference:WaitForChild("RecipeReference"))

local function onPotionPromptTriggered(player)
	PotionCreation.initialize(player, PotionPrompt)
end

PotionPrompt.Triggered:Connect(onPotionPromptTriggered)

local function onRecipeReferencePrompt(player)
	RecipeReference.MoveCamera(player, RecipeReferencePrompt.Parent.Parent.Parent)
end

RecipeReferencePrompt.Triggered:Connect(onRecipeReferencePrompt)