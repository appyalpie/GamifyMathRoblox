-- Get the MusicEvent from replicated storage (MusicInit.server.lua)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local musicEvent = ReplicatedStorage:WaitForChild('MusicEvent')
local lastSound

musicEvent.OnClientEvent:Connect(function(musicId, volume)
    -- If lastSound does not exist or lastSound =/= this new one
    if not lastSound or lastSound.SoundId ~= musicId then
        -- If last sound DOES exist, stop and destroy it to save space
        if lastSound then
            lastSound:Stop()
            lastSound:Destroy()
        end
        
        -- Instance the new sound, make it looped
        local sound = Instance.new("Sound", workspace.Sounds)
        sound.SoundGroup = workspace.Sounds.MusicSoundGroup
        sound.SoundId = musicId
        sound.Volume = volume
        sound.Looped = true

        --Play the new sound, set the lastSound = this one so we don't replay sounds
    
        sound:Play()
        lastSound = sound
    end
end)