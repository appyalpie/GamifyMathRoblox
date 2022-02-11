-- Check if MusicEvent exists, if not , make it
if not(game.ReplicatedStorage:FindFirstChild('MusicEvent')) then
    Instance.new("RemoteEvent", game.ReplicatedStorage).Name = 'MusicEvent'
end

-- Find and set variable musicEvent to the new event
local musicEvent = game.ReplicatedStorage:FindFirstChild('MusicEvent')

--Sets song zones to play their attribute "songId" when touched
for i,v in pairs(workspace.Sounds.MusicZones:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Touched:Connect(function(objectHit)
            if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then
                -- Fires the musicevent client on server side (PlayMusicLocal.client.lua)
                musicEvent:FireClient(game.Players:GetPlayerFromCharacter(objectHit.Parent),v:GetAttribute("songId"), v:GetAttribute("Volume"))
            end
        end)
    end
end
