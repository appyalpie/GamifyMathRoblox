local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerCheckpointsStore = DataStoreService:GetDataStore("PlayerCheckpoints")

local CheckpointUtilities = require(script.CheckpointUtilities)

local BlurRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BlurRE")
local ClientReadyCheckpointRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ClientReadyCheckpointRE")
local SetCheckpointOnStartRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetCheckpointOnStartRE")
local MovePlayerToCheckpointRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("MovePlayerToCheckpointRE")

------ Retrieve Player Set Checkpoint + List of Gotten Checkpoints (if any) ------
Players.PlayerAdded:Connect(function(player)
    local success, returnedValue = pcall(function()
        return PlayerCheckpointsStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or typeof(returnedValue) ~= "table" then
            player:SetAttribute("current_checkpoint", 0)
            CheckpointUtilities.initializeCheckpoints(player, {})
        else
            player:SetAttribute("current_checkpoint", returnedValue[1])
            CheckpointUtilities.initializeCheckpoints(player, returnedValue[2])
        end
    end

    ------ Player Respawns at Most Recently Saved Checkpoint ------
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
    local playerCheckpointNum = player:GetAttribute("current_checkpoint")
    local playerCheckpoints = CheckpointUtilities.getCheckpoints(player)
    local success, errorMessage = pcall(function()
        PlayerCheckpointsStore:SetAsync(player.UserId, {playerCheckpointNum, playerCheckpoints})
    end)
    if not success then
        print(errorMessage)
    end
end)

ClientReadyCheckpointRE.OnServerEvent:Connect(function(player)
    SetCheckpointOnStartRE:FireClient(player, player:GetAttribute("current_checkpoint"))
end)


-- set all Checkpoint events
CheckpointUtilities.setCheckpointEvents()

-- Client requests a move
MovePlayerToCheckpointRE.OnServerEvent:Connect(function(player, checkpoint)
    if not player.Character or not player.Character.Parent then -- need to wait for the player's character to actually load in first
        player.Character = player.CharacterAdded:Wait()
    end
    CheckpointUtilities.moveCharacterToCheckpoint(player.Character, checkpoint)
end)