
local CheckpointUtilities = {}

local allCheckpoints = game.Workspace.Island_1.Checkpoints:GetChildren() -- get all checkpoints from Workspace

-- function to move a character to their checkpoint
function CheckpointUtilities.moveCharacterToCheckpoint(character)
    local playerCheckpoint = game.Players:GetPlayerFromCharacter(character):GetAttribute("checkpoint")
    for i, v in pairs(allCheckpoints) do
        if v:GetAttribute("checkpointNum") and v:GetAttribute("checkpointNum") == playerCheckpoint then
            wait() -- Cannot move instance immediately after it is created
            character:SetPrimaryPartCFrame(v.CFrame + Vector3.new(0, 4, 0))
            break;
        end
    end
end

--call once to set checkpoint touched to set the player's checkpoint
function CheckpointUtilities.setCheckpointEvents()
    for i, v in pairs (allCheckpoints) do
        v.Touched:Connect(function(objectHit)
            if objectHit and objectHit.Parent and objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then
                local character = objectHit.Parent
                local player = game.Players:GetPlayerFromCharacter(character)
                player:SetAttribute("checkpoint", v:GetAttribute("checkpointNum"))
            end
        end)
    end
end

return CheckpointUtilities
