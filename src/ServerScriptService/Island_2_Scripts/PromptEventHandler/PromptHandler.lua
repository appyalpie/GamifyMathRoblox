local ServerScriptService = game:GetService("ServerScriptService")

local Game_24 = require(ServerScriptService.Island_2_Scripts:WaitForChild("Game_24"))

local PromptHandler = {}

function PromptHandler.onPromptTriggered(promptObject, player)
	local ancestorModel = promptObject:FindFirstAncestorWhichIsA("Model")
	
	if ancestorModel and ancestorModel.Name == "24_Pedistal" then -- configure info module
		-- Initialize 24 Game Single Player Mode
		Game_24.initialize(promptObject, player)
	--TODO: Make less jank (thanks eric)
	elseif ancestorModel and (ancestorModel.Name == "Opponent" or ancestorModel.Name == "Tommy's Winning Robot")then
		-- Initialize 24 Game NPC Challenger Mode
		Game_24.initializeNPC(promptObject, player)
	end
end

return PromptHandler
