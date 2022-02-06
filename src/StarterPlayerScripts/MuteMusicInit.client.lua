--local starterGui = game:GetService("StarterGui")
local client = game:GetService("Players").LocalPlayer
local playerGui = client:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("PersistentUI")
local muteMusicButton = screenGui:FindFirstChildWhichIsA("TextButton")

for i,v in pairs(playerGui:GetChildren()) do
    print(v.Name)
end

muteMusicButton.Activated:Connect(function()
    print('muteMusic hit')
    local soundToMute = workspace.Sounds:FindFirstChild("Sound")
    soundToMute:Pause()
    muteMusicButton.Text = "Unmute Music"
end)