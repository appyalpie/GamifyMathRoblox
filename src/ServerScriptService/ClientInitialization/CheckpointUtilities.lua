local disabled = true
if disabled then
    return
end

--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckpointsRE = ReplicatedStorage.RemoteEvents:WaitForChild("CheckpointsRE")


local CheckpointUtilities = {}
local ProximityPrompts = {}

local allCheckpoints = game.Workspace.Checkpoints:GetChildren() -- get all checkpoints from Workspace

-- function to move a character to their checkpoint
function CheckpointUtilities.moveCharacterToCheckpoint(character)
    local playerCheckpoint = game.Players:GetPlayerFromCharacter(character):GetAttribute("checkpoint")
    for i, v in pairs(allCheckpoints) do
        if v:GetAttribute("checkpointNum") and v:GetAttribute("checkpointNum") == playerCheckpoint then
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
