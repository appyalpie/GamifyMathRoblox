--local starterGui = game:GetService("StarterGui")
local client = game:GetService("Players").LocalPlayer
local playerGui = client:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("PersistentUI")
local muteMusicButton = screenGui:FindFirstChildWhichIsA("TextButton")

muteMusicButton.Activated:Connect(function()
    local soundGroupToMute = workspace.Sounds:FindFirstChildWhichIsA("SoundGroup")
    if soundGroupToMute.Volume ~= 0 then
        soundGroupToMute.Volume = 0
        muteMusicButton.Text = "Unmute Music"
    end
    if soundGroupToMute.Volume == 0 then
        soundGroupToMute.Volume = 0.5
        muteMusicButton.Text = "Mute Music"
    end

end)