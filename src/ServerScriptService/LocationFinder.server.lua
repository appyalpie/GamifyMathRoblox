-- Check if LocationEvent exists, if not , make it
if not(game.ReplicatedStorage:FindFirstChild('LocationEvent')) then
    Instance.new("RemoteEvent", game.ReplicatedStorage).Name = 'LocationEvent'
end

-- Find and set variable locationEvent to the new event
local locationEvent = game.ReplicatedStorage:FindFirstChild('LocationEvent')

--handle the collision and pass the player and the zone name in fire client
for i,v in pairs(workspace.Locations:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Touched:Connect(function(objectHit)
            if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then  
                locationEvent:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent), v.Name)
                      
            end
        end)
    end
end