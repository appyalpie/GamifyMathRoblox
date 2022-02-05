local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local MathBlocksInfo = require(script.Parent.MathBlocksInfo)

local CollisionUtilities = {}

local function setScreenGuis(block)
    local combinedBlockDescendants = block:GetDescendants()
    for _, v in pairs (combinedBlockDescendants) do
        if v:IsA("TextLabel") then
            v.Text = block:GetAttribute("value")
        end
    end
end

local function resetAssemblyVelocity(block)
    block.AssemblyLinearVelocity = Vector3.new(0,0,0)
    block.AssemblyAngularVelocity = Vector3.new(0,0,0)
end
--[[
    Handle Tweening of Position, Size, Transparency, Orientation for Combine
        Particle Emitter Core
        Successful Combine Explosion
        Tweening of Position, Transparency, Orientation for Combined Block
--]]
local function twoBlocksCollisionEffects(block_1, block_2, combinedBlock)
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

    tweenPositionSizeBlock1:Play()
    tweenPositionSizeBlock2:Play()

    local tweenCompletedConnection
    tweenCompletedConnection = tweenPositionSizeBlock2.Completed:Connect(function()
        tweenCompletedConnection:Disconnect()
        block_1:Destroy()
        block_2:Destroy()
        -- Math Explosion
        combineParticlesCore.Add_Particles:Emit(50)

        -- Anchor combined block (avoids annoying gravity physics)
        combinedBlock.Anchored = true

        -- add tween for new block to be tweened in
        combinedBlock.Transparency = 1
        combinedBlock.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
        local sizeAndPosTween = TweenService:Create(combinedBlock, tweenInfo, {Position = targetCFrame.Position,
            Transparency = 0, Orientation = Vector3.new(0,0,0)})
        sizeAndPosTween:Play()
        local conn
        conn = sizeAndPosTween.Completed:Connect(function()
            combinedBlock.CanTouch = true
            resetAssemblyVelocity(combinedBlock)
            combinedBlock.Anchored = false
            conn:Disconnect()
        end)
    end)
end

local function explosionCollisionProcessing(block_1, block_2, operator)
    local targetCFrame = block_1.CFrame:Lerp(block_2.CFrame, 0.5) + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
    local ExplosionInfo = MathBlocksInfo.ExplosionTweenInfo
    local explosionTweenInfo = TweenInfo.new(ExplosionInfo.Time, ExplosionInfo.EasingStyle, ExplosionInfo.EasingDirection)
    local tweenBlock1 = TweenService:Create(block_1, explosionTweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = ExplosionInfo.Properties.Size, Transparency =  ExplosionInfo.Properties.Transparency, Orientation = block_1.Orientation + ExplosionInfo.Properties.Orientation})
    local tweenBlock2 = TweenService:Create(block_2, explosionTweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = ExplosionInfo.Properties.Size, Transparency = ExplosionInfo.Properties.Transparency, Orientation = block_2.Orientation + ExplosionInfo.Properties.Orientation})

    -- particles
    local explosionParticlesCore = MathBlocksInfo.EXPLOSION_PARTICLES_CORE:Clone()
    explosionParticlesCore.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
    explosionParticlesCore.Parent = MathBlocksInfo.EFFECTS_FOLDER
    local turnOffEffectsCoroutine = coroutine.wrap(function()
        wait(4) -- TODO: set to static from module
        for _, v in pairs(explosionParticlesCore.Attachment:GetChildren()) do
            v.Enabled = false
        end
        explosionParticlesCore.Sparks.Enabled = false
    end)
    turnOffEffectsCoroutine()
    Debris:AddItem(explosionParticlesCore, 6)

    tweenBlock1:Play()
    tweenBlock2:Play()

    local tweenCompletedConnection
    tweenCompletedConnection = tweenBlock1.Completed:Connect(function()
        tweenCompletedConnection:Disconnect()
        block_1:Destroy()
        block_2:Destroy()
        -- Math Explosion
        explosionParticlesCore.Dirt:Emit(50)
        explosionParticlesCore.Explosion_Random:Emit(50) --TODO: Set to some random decal
        explosionParticlesCore.Heat:Emit(50)
        explosionParticlesCore.Shockwave:Emit(50)
    end)
end

local function successfulCollisionProcessing(block_1, block_2, operator)
    block_1.Anchored = true -- Prevent weird gravity interaction while tweening
    block_2.Anchored = true
    block_1.CanTouch = false -- Disallow further interaction while combining TODO: Change if model is used and not a part
    block_2.CanTouch = false

    if operator == MathBlocksInfo.ADD_BLOCK_TAG then
        local combinedBlock = MathBlocksInfo.ADD_BLOCK:Clone() -- Clone, Tag functionality, Set Attr, and sent to workspace
        combinedBlock.CanTouch = false
        CollectionService:AddTag(combinedBlock, MathBlocksInfo.ADD_BLOCK_TAG)
        combinedBlock:SetAttribute("value", block_1:GetAttribute("value") + block_2:GetAttribute("value"))
        combinedBlock.Parent = MathBlocksInfo.ADD_BLOCKS_FOLDER

        -- set screenGuis
        setScreenGuis(combinedBlock)

        -- VFX
        twoBlocksCollisionEffects(block_1, block_2, combinedBlock)
    end
end

function CollisionUtilities.additionCollisionProcessing(block_1, block_2)
    if not block_1:GetAttribute("operator") == "add" or not block_2:GetAttribute("operator") == "add" then
        -- TODO: Explosion for invalid operator combining
        print("Invalid")
    elseif block_1:GetAttribute("value") + block_2:GetAttribute("value") > MathBlocksInfo.ADD_LIMIT then
        -- TODO: Explosion for max exceeded
        print("MAX EXCEEDED EXPLOSION IMMINENT")
        explosionCollisionProcessing(block_1, block_2, MathBlocksInfo.ADD_BLOCK_TAG)
    else
        successfulCollisionProcessing(block_1, block_2, MathBlocksInfo.ADD_BLOCK_TAG)
    end
end

return CollisionUtilities