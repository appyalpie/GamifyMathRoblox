local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local PotionStatus = RemoteEvents.PotionStatus
local PotionParticleRE = RemoteEvents.PotionParticleRE

PotionStatus.OnClientEvent:Connect(function(status)
    PotionStatus:FireServer(status)
end)
PotionParticleRE.OnClientEvent:Connect(function(color)
    PotionParticleRE:FireServer(color)
end)
