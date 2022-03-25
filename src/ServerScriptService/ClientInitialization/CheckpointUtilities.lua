
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
    --local Player = game:GetService("Players").LocalPlayer --need the player
    for _, v in pairs (allCheckpoints) do 
       if v:IsA("Model") then
        --get the proximity prompts from the checkpoints that have them
        local Energyball = v:FindFirstChild("Energyball") --returns nil
        local ProximityPrompt = Energyball:FindFirstChild("ProximityPrompt") --this isn't working

        --instead of touch need to be set by proximity prompt located in checkpoints.Checkpoint.Energyball.ProximityPrompt (part of model)

        
        if ProximityPrompt then
            table.insert(ProximityPrompts, ProximityPrompt)
            ProximityPrompt.Triggered:Connect(function(player)
                
                --set the checkpoint to the player
                player:SetAttribute("checkpoint", v:GetAttribute("checkpointNum"))

                for _, c in pairs (ProximityPrompts) do
                    
                    if c.Enabled == true then
                        continue
                    end

                    c.Enabled = true

                    --handle the colors
                    local AncestorModel = c:FindFirstAncestorWhichIsA("Model")
                    local CoreAttachment = AncestorModel.Energyball.CoreAttachment
                    CoreAttachment.Core.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(42,255,248)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(42,255,248))
                    }
                    
                    CoreAttachment.OuterCore.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(42,255,248)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(42,255,248))
                    }
                    
                    CoreAttachment.Shine.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(42,255,248)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(42,255,248))
                    }
                end
               
                ProximityPrompt.Enabled = false
                --turn to yellow
                local AncestorModel = ProximityPrompt:FindFirstAncestorWhichIsA("Model")
                local CoreAttachment = AncestorModel.Energyball.CoreAttachment

                CoreAttachment.Core.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 28)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 28))
                }
                CoreAttachment.OuterCore.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 28)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 28))
                }
                
                CoreAttachment.Shine.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,28)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,170,28))
                }
  
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
