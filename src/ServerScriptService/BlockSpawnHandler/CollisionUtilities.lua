local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local MathBlocksInfo = require(script.Parent.MathBlocksInfo)

local CollisionUtilities = {}

local function resetAssemblyVelocity(block)
    block.AssemblyLinearVelocity = Vector3.new(0,0,0)
    block.AssemblyAngularVelocity = Vector3.new(0,0,0)
end

local function collisionProcessingVFX(block_1, block_2, operator)
    block_1.Anchored = true -- Prevent weird gravity interaction while tweening
    block_2.Anchored = true
    block_1.CanTouch = false -- Disallow further interaction while combining TODO: Change if model is used and not a part
    block_2.CanTouch = false

    if operator == MathBlocksInfo.ADD_BLOCK_TAG then
        local combinedBlock = MathBlocksInfo.ADD_BLOCK:Clone() -- Clone, Tag functionality, Set Attr, and sent to workspace
        CollectionService:AddTag(combinedBlock, MathBlocksInfo.ADD_BLOCK_TAG)
        combinedBlock:SetAttribute("value", block_1:GetAttribute("value") + block_2:GetAttribute("value"))
        combinedBlock.Parent = MathBlocksInfo.ADD_BLOCKS_FOLDER

        -- tween size and position
        local targetCFrame = block_1.CFrame:Lerp(block_2.CFrame, 0.5) + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME -- CFrame of middle of two blocks
        local tweenInfo = TweenInfo.new(MathBlocksInfo.TweenInfo.Time, MathBlocksInfo.TweenInfo.EasingStyle, MathBlocksInfo.TweenInfo.EasingDirection)
        local tweenPositionSizeBlock1 = TweenService:Create(block_1, tweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
        Size = MathBlocksInfo.TweenInfo.Properties.Size, Transparency = MathBlocksInfo.TweenInfo.Properties.Transparency, Orientation = block_1.Orientation + Vector3.new(90,90,90)})
        local tweenPositionSizeBlock2 = TweenService:Create(block_2, tweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
        Size = MathBlocksInfo.TweenInfo.Properties.Size, Transparency = MathBlocksInfo.TweenInfo.Properties.Transparency, Orientation = block_2.Orientation + Vector3.new(90,90,90)})

        -- particles
        local combineParticlesCore = MathBlocksInfo.COMBINE_PARTICLES_CORE:Clone()
        combineParticlesCore.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
        combineParticlesCore.Parent = MathBlocksInfo.EFFECTS_FOLDER
        local turnOffEffectsCoroutine = coroutine.wrap(function()
            wait(4) -- TODO: set to static from module
            for _, v in pairs(combineParticlesCore.Attachment:GetChildren()) do
                v.Enabled = false
            end
        end)
        turnOffEffectsCoroutine()
        Debris:AddItem(combineParticlesCore, 6)
        
        --[[
         add rotation
        local function addRotationToBlock(block)
            local attachment0 = Instance.new("Attachment")
            attachment0.Parent = block
            attachment0.Position = MathBlocksInfo.AttachmentInfo.Position
            
            local angularVelocity = Instance.new("AngularVelocity")
            angularVelocity.Parent = block
            angularVelocity.MaxTorque = MathBlocksInfo.AngularVelocityInfo.MaxTorque
            angularVelocity.AngularVelocity = MathBlocksInfo.AngularVelocityInfo.AngularVelocity
            angularVelocity.Attachment0 = attachment0
        end
        addRotationToBlock(block_1)
        addRotationToBlock(block_2)
        --]]
        
        tweenPositionSizeBlock1:Play()
        tweenPositionSizeBlock2:Play()

        local tweenCompletedConnection
        tweenCompletedConnection = tweenPositionSizeBlock2.Completed:Connect(function()
            tweenCompletedConnection:Disconnect()
            block_1:Destroy()
            block_2:Destroy()
            -- Math Explosion
            combineParticlesCore.Add_Particles:Emit(50)

            -- add some body velocity for anti-grav
            combinedBlock.Anchored = true
            --local bodyVelocity = Instance.new("BodyVelocity")
            --bodyVelocity.Velocity = Vector3.new(0,workspace.Gravity*combinedBlock.Mass,0)
            --bodyVelocity.Parent = combinedBlock
            -- add tween for new block to be tweened in
            combinedBlock.CanTouch = false
            combinedBlock.Transparency = 1
            combinedBlock.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
            local sizeAndPosTween = TweenService:Create(combinedBlock, tweenInfo, {Position = targetCFrame.Position,
                Transparency = 0, Orientation = Vector3.new(0,0,0)})
            sizeAndPosTween:Play()
            local conn
            conn = sizeAndPosTween.Completed:Connect(function()
                combinedBlock.CanTouch = true
                --bodyVelocity:Destroy()
                resetAssemblyVelocity(combinedBlock)
                combinedBlock.Anchored = false
                conn:Disconnect()
            end)
        end)
    end
end

function CollisionUtilities.additionCollisionProcessing(block_1, block_2)
    if not block_1:GetAttribute("operator") == "add" or not block_2:GetAttribute("operator") == "add" then
        -- TODO: Explosion for invalid operator combining
        print("Invalid")
    elseif block_1:GetAttribute("value") + block_2:GetAttribute("value") > MathBlocksInfo.ADD_LIMIT then
        -- TODO: Explosion for max exceeded
        print("MAX EXCEEDED EXPLOSION IMMINENT")
    else
        collisionProcessingVFX(block_1, block_2, MathBlocksInfo.ADD_BLOCK_TAG)
    end
end

return CollisionUtilities