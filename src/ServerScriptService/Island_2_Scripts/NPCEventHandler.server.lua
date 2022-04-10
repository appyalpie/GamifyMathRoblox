local ServerScriptService = game:GetService("ServerScriptService")

local Game_24 = require(ServerScriptService.Island_2_Scripts:WaitForChild("Game_24"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChallengeEvent = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("ChallengeEvent")

ChallengeEvent.OnServerEvent:Connect(function(player, promptObject)
    print(promptObject.Name)
    print(player.Name)
    Game_24.initializeNPC(promptObject, player)
end)