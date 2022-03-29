local PotionStatus = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("PotionStatus")
PotionStatus.OnClientEvent:Connect(function(Status)
	PotionStatus:FireServer(Status)
end)
