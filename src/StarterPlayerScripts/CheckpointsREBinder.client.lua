--get services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CheckpointsRE = ReplicatedStorage.RemoteEvents:WaitForChild("CheckpointsRE")

--variables
local allCheckpoints = game.Workspace.Checkpoints:GetChildren()

CheckpointsRE.OnClientEvent:Connect(function(TargetProximityPrompt)
    
        for _, v in pairs (allCheckpoints) do 
           if v:IsA("Model") then
                --get the proximity prompts from the checkpoints that have them
                local Energyball = v:FindFirstChild("Energyball") 
                local ProximityPrompt = Energyball:FindFirstChild("ProximityPrompt") 
    
                --instead of touch need to be set by proximity prompt located in checkpoints.Checkpoint.Energyball.ProximityPrompt (part of model)
                if ProximityPrompt then
                    
                    if ProximityPrompt.Enabled then
                        continue
                    end

                    --handle the colors
                    local AncestorModel = ProximityPrompt:FindFirstAncestorWhichIsA("Model")
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
                    ProximityPrompt.Enabled = true
                end
            end
        end

        TargetProximityPrompt.Enabled = false
                
        --turn to green
        local AncestorModel = TargetProximityPrompt:FindFirstAncestorWhichIsA("Model")
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