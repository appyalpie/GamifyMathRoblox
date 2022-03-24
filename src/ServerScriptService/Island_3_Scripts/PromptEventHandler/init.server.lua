local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PotionPrompt = Workspace.Island_3.test_zone.Beaker.Beaker.PromptAttachment.ProximityPrompt
local PotionCreation = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionCreation"))

local function onPromptTriggered(player)
	PotionCreation.initialize(player, PotionPrompt)
end

PotionPrompt.Triggered:Connect(onPromptTriggered)