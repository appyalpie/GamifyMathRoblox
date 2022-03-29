local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local allCombinationTables = Workspace.Island_3.Islands.PotionCreationTables:GetChildren()
local PotionPrompts = {}
local RecipeReferencePrompts = {}

local PotionCreation = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionCreation"))
local RecipeReference = require(ServerScriptService.Island_3_Scripts:WaitForChild("RecipeReference"))

for _,combinationTable in pairs(allCombinationTables) do
	table.insert(PotionPrompts, combinationTable.Beaker.Beaker.PromptAttachment.ProximityPrompt)
	table.insert(RecipeReferencePrompts, combinationTable.PaperHolder.PromptAttachment.ProximityPrompt)
end

for _,prompt in pairs(PotionPrompts) do
	prompt.Triggered:Connect(function(player)
		PotionCreation.initialize(player, prompt)
	end)
end

for _,paperPrompt in pairs(RecipeReferencePrompts) do
	paperPrompt.Triggered:Connect(function(player)
		RecipeReference.MoveCamera(player, paperPrompt.Parent.Parent.Parent)
	end)
end