local ProximityPromptService = game:GetService("ProximityPromptService")

local PromptHandler = require(script:WaitForChild("PromptHandler"))

local function onPromptTriggered(promptObject, player)
	PromptHandler.onPromptTriggered(promptObject, player)
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)