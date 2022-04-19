local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local CheckpointTag = "Checkpoint"

local OpenCheckpointWarpGuiRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("OpenCheckpointWarpGuiRE")
local PlayCheckpointEffectsRE = ReplicatedStorage.RemoteEvents.CheckpointRE:WaitForChild("PlayCheckpointEffectsRE")

local CheckpointUtilities = {}

local ProximityPrompts = {}

local PlayerCheckpointsListing = {}

------ Initialize Checkpoints ------
CheckpointUtilities.initializeCheckpoints = function(player, checkpointData)
    PlayerCheckpointsListing[player.UserId] = checkpointData
end

CheckpointUtilities.getCheckpoints = function(player)
    return PlayerCheckpointsListing[player.UserId]
end

------ Move Character to Checkpoint ------
CheckpointUtilities.moveCharacterToCheckpoint = function(character, checkpoint)
    if checkpoint then
        for _, v in pairs(CollectionService:GetTagged(CheckpointTag)) do
            if v:GetAttribute("checkpoint_num") and v:GetAttribute("checkpoint_num") == checkpoint then
                wait() -- Cannot move instance immediately after it is created
                if v:IsA("Model") then
                    character:SetPrimaryPartCFrame(CFrame.new(v.Checkpoint.Position + Vector3.new(0, 4, 0)))
                end
                return
            end
        end
    end

    local playerCheckpoint = game.Players:GetPlayerFromCharacter(character):GetAttribute("current_checkpoint")
    for _, v in pairs(CollectionService:GetTagged(CheckpointTag)) do
        if v:GetAttribute("checkpoint_num") and v:GetAttribute("checkpoint_num") == playerCheckpoint then
            wait() -- Cannot move instance immediately after it is created
            if v:IsA("Model") then
                character:SetPrimaryPartCFrame(CFrame.new(v.Checkpoint.Position + Vector3.new(0, 4, 0)))
            end
            return
        end
    end
end

------ Set ProxPrompts to Open Warp Menu + Hitboxes Set Checkpoint and Trigger Visual and Sound Effects ------
CheckpointUtilities.setCheckpointEvents = function()
    for _, v in pairs (CollectionService:GetTagged(CheckpointTag)) do
        local ProximityPrompt = v.PromptPart.PromptAttachment.ProximityPrompt

        if ProximityPrompt then
            table.insert(ProximityPrompts, ProximityPrompt)
            ProximityPrompt.Triggered:Connect(function(player)
                OpenCheckpointWarpGuiRE:FireClient(player, ProximityPrompt, PlayerCheckpointsListing[player.UserId])
            end)
        end

        local Hitbox = v:FindFirstChild("Hitbox")

        if Hitbox then
            Hitbox.Touched:Connect(function(objectHit)
                if objectHit.Parent and objectHit.Parent:FindFirstChild("Humanoid") then
                    local character = objectHit.Parent
                    local player = Players:GetPlayerFromCharacter(character)

                    if v:GetAttribute("checkpoint_num") == player:GetAttribute("current_checkpoint") then return end

                    player:SetAttribute("current_checkpoint", v:GetAttribute("checkpoint_num"))
                    if table.find(PlayerCheckpointsListing[player.UserId], v:GetAttribute("checkpoint_num")) == nil then
                        table.insert(PlayerCheckpointsListing[player.UserId], v:GetAttribute("checkpoint_num"))
                    end
                    PlayCheckpointEffectsRE:FireClient(player, v)
                end
            end)
        end
    end
end


return CheckpointUtilities
