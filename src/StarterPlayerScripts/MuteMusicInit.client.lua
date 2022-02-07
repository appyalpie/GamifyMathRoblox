-- Gets music button from the players local UI. 
-- note: WaitForChild MUST be used to find UI elements from PlayerGui due to load times
local muteMusicButton = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PersistentUI"):FindFirstChildWhichIsA("TextButton")

muteMusicButton.Activated:Connect(function()
    -- Fetch the SoundGroup that music is stored under
    local soundGroupToMute = workspace.Sounds:FindFirstChild("MusicSoundGroup")
    -- Check if volume is NOT 0. If it is NOT 0, mute the SoundGroup, otherwise if it IS 0, set the SoundGroup Volume multiplier to 1
    if soundGroupToMute.Volume ~= 0 
    then
        print("time to mute")
        soundGroupToMute.Volume = 0
        muteMusicButton.Text = "Unmute Music"
    else
        soundGroupToMute.Volume = 1
        muteMusicButton.Text = "Mute Music"
    end

end)