local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local CheckpointTag = "Checkpoint"

local CheckpointsRE = ReplicatedStorage.RemoteEvents:WaitForChild("CheckpointsRE")

local CheckpointUtilities = {}

local ProximityPrompts = {}

------ Move Character to Checkpoint ------
CheckpointUtilities.moveCharacterToCheckpoint = function(character)
    local playerCheckpoint = game.Players:GetPlayerFromCharacter(character):GetAttribute("current_checkpoint")
    for _, v in pairs(CollectionService:GetTagged(CheckpointTag)) do
        if v:GetAttribute("checkpoint_num") and v:GetAttribute("checkpoint_num") == playerCheckpoint then
            wait() -- Cannot move instance immediately after it is created
            if v:IsA("Model") then
                character:SetPrimaryPartCFrame(v.Energyball.CFrame + Vector3.new(7, 4, 0))
            else
                character:SetPrimaryPartCFrame(v.CFrame + Vector3.new(2, 4, 0)) --for pads
            end
            break;
        end
    end
end

--call once to set checkpoint touched to set the player's checkpoint--going to change this to an interaction
function CheckpointUtilities.setCheckpointEvents()
    for _, v in pairs (allCheckpoints) do 
       if v:IsA("Model") then
        --get the proximity prompts from the checkpoints that have them
        local Energyball = v:FindFirstChild("Energyball") 
        local ProximityPrompt = Energyball:FindFirstChild("ProximityPrompt") 

        --instead of touch need to be set by proximity prompt located in checkpoints.Checkpoint.Energyball.ProximityPrompt (part of model)
        if ProximityPrompt then
            table.insert(ProximityPrompts, ProximityPrompt)
            ProximityPrompt.Triggered:Connect(function(player)
                CheckpointsRE:FireClient(player, ProximityPrompt)
                --set the checkpoint to the player
                player:SetAttribute("checkpoint", v:GetAttribute("checkpointNum"))

            end)
        end  

       else
            --touch code for old checkpoints
            v.Touched:Connect(function(objectHit)
                if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then
                    local character = objectHit.Parent
                    local player = game.Players:GetPlayerFromCharacter(character)
                    player:SetAttribute("checkpoint", v:GetAttribute("checkpointNum"))
                end
            end)
       end
    end
end

return CheckpointUtilities
