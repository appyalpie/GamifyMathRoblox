local disabled = true
if disabled then
    return
end

--services and variables up top. allow access to globaldatastore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local checkpointStore = DataStoreService:GetDataStore("PlayerCheckpoints")
--get module
local CheckpointUtilities = require(script.CheckpointUtilities)
local BlurRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BlurRE")
local ClientReadyCheckpointRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ClientReadyCheckpointRE")
local SetCheckpointOnStartRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetCheckpointOnStartRE")

--connects the event of adding a player to checkpoint
Players.PlayerAdded:Connect(function(player)
    -- set the player's "checkpoint" value v    ia datastore info, or if no datastore just set to 0
    local checkpointValue = 0

    --handling errors
    local success, returnedValue = pcall(function()
        return checkpointStore:GetAsync(player.UserId)
    end)

    if success then --successfully got checkpointInformation
        if returnedValue == nil then -- on the intial load, we might successfully get nil
            checkpointValue = 0
        else
            checkpointValue = returnedValue
        end
    end
    --making the attibrute checkpoint the move function will use and set to value
    player:SetAttribute("checkpoint", checkpointValue)

    -- connect function which sends player to their checkpoint level should they die
    player.CharacterAdded:Connect(function(character)
        CheckpointUtilities.moveCharacterToCheckpoint(character)
    end)    

    -- move the player to their checkpoint level (initial move)
    if not player.Character or not player.Character.Parent then -- need to wait for the player's character to actually load in first
        player.Character = player.CharacterAdded:Wait()
    end
    CheckpointUtilities.moveCharacterToCheckpoint(player.Character)

    local screengui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

    if player:GetAttribute("checkpoint") == 0 then
        screengui.Enabled = true
        BlurRE:FireClient(player)
    end
end)

-- when the player leaves, save their current checkpoint
Players.PlayerRemoving:Connect(function(player)
    local playerCheckpointNum = player:GetAttribute("checkpoint")
    local success, errorMessage = pcall(function()
        checkpointStore:SetAsync(player.UserId, playerCheckpointNum)
    end)
    if not success then
        print(errorMessage)
    end
end)

ClientReadyCheckpointRE.OnServerEvent:Connect(function(player)
    SetCheckpointOnStartRE:FireClient(player, player:GetAttribute("checkpoint"))
    
end)


-- set all Checkpoint events
CheckpointUtilities.setCheckpointEvents()
