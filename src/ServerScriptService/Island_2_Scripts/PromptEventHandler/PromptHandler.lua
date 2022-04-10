local ServerScriptService = game:GetService("ServerScriptService")

local Game_24 = require(ServerScriptService.Island_2_Scripts:WaitForChild("Game_24"))

local PromptHandler = {}

function PromptHandler.onPromptTriggered(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")
	
	if ancestorModel and ancestorModel.Name == "24_Pedistal" then -- configure info module
		-- Initialize 24 Game Single Player Mode
		Game_24.initialize(promptObject, player)
	elseif ancestorModel and ancestorModel.Name == "Competitive_Arena" then
		--[[
			1. Disable the prompt, increment number of players, tie events to death and leave
			2. Check if another player is already queued up
		]]
		print("Got Request")
		Game_24.preInitializationCompetitive(promptObject, player)
	elseif ancestorModel and ancestorModel.Name == "24_Pedistal_Timed" then
		Game_24.initializeTimed(promptObject, player)
	end
end

return PromptHandler
