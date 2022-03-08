-- Check if ChallengeEvent exists, if not , make it
if not(game.ReplicatedStorage:FindFirstChild('ChallengeEvent')) then
    Instance.new("RemoteEvent", game.ReplicatedStorage).Name = 'ChallengeEvent'
end

-- Find and set variable ChallengeEvent to the new event
local ChallengeEvent = game.ReplicatedStorage:FindFirstChild('ChallengeEvent')

--handles what exactly
for i,v in pairs(workspace.Locations:GetDescendants()) do --needs to be fixed use proximity prompt?
    if v:IsA("BasePart") then
        v.Touched:Connect(function(objectHit)
            if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then  --for collision. this right?
                ChallengeEvent:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent), v.Name) --send the player and what else?
                      
            end
        end)
    end
end