local ServerScriptService = game:GetService("ServerScriptService")

local Game_24 = require(ServerScriptService.Island_2_Scripts:WaitForChild("Game_24"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InitiateNPCChallengeRE = ReplicatedStorage.RemoteEvents.Island_2.InitiateNPCChallengeRE

InitiateNPCChallengeRE.OnServerEvent:Connect(function(promptObject, player)
    Game_24.initializeNPC(promptObject, player)
end)