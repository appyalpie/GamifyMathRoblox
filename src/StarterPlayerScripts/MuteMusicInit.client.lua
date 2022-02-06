local starterGui = game:GetService("StarterGui")
local screenGui = starterGui:FindFirstChild("PersistentUI")
local muteMusicButton = screenGui:FindFirstChildWhichIsA("TextButton")

print(muteMusicButton.Text)
muteMusicButton.Text = "Unmute Music"

muteMusicButton.Activated:Connect(function()
    print('muteMusic hit')
    local soundToMute = workspace.Sounds:FindFirstChild("Sound")
    soundToMute:Pause()
end)