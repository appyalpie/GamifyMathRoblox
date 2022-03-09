-- Get the MusicEvent from replicated storage (MusicInit.server.lua)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local musicEvent = ReplicatedStorage:WaitForChild('MusicEvent')
local lastSound
local battleSound

local function CreateMusic(musicId, volume)
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
        if musicId == "lastsound" then
            sound.SoundId = lastSound.SoundId
            sound.Volume = lastSound.volume
            sound.Looped = true
            if battleSound then
                battleSound:Stop()
                battleSound:Destroy()
            end
        else
            sound.SoundId = musicId
            sound.Volume = volume
            sound.Looped = true
        end


        --Play the new sound, set the lastSound = this one so we don't replay sounds
    
        sound:Play()
        if musicId == "rbxassetid://9042916394" then
            sound.Looped = false
            repeat wait() until sound.IsPaused == true
            sound.SoundId = "rbxassetid://9042922451"
            sound.Looped = true
            sound:Play()
            battleSound = sound
            return
        elseif musicId == "rbxassetid://9042934109" then
            battleSound = sound
            return
        end
        lastSound = sound
    end
end

musicEvent.OnClientEvent:Connect(CreateMusic)

