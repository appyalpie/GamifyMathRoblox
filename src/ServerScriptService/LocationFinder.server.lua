local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Island3EnteredRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("Island3EnteredEvent")
local Island3ExitRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("Island3ExitEvent")

-- Check if LocationEvent exists, if not , make it
if not(game.ReplicatedStorage:FindFirstChild('LocationEvent')) then
    Instance.new("RemoteEvent", game.ReplicatedStorage).Name = 'LocationEvent'
end

local TitleModule = require(ServerScriptService:WaitForChild("TitleModule"))

-- Find and set variable locationEvent to the new event
local locationEvent = game.ReplicatedStorage:FindFirstChild('LocationEvent')

--handle the collision and pass the player and the zone name in fire client
for i,v in pairs(workspace.Locations:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Touched:Connect(function(objectHit)
            if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then  
                locationEvent:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent), v.Name)
                if v.Name == "Champions Club" then
                    TitleModule.AddTitleToUser(game.Players:GetPlayerFromCharacter(objectHit.Parent), 2)
                end
                if v.Name == "Island 3" then
                    Island3EnteredRE:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent))
                else
                    Island3ExitRE:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent))
                end
            end
        end)
    end
end