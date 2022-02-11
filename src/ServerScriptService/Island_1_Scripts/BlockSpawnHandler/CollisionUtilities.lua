local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local MathBlocksInfo = require(script.Parent.MathBlocksInfo)

local CollisionUtilities = {}

CollisionUtilities.setScreenGuis = function(block)
    local combinedBlockDescendants = block:GetDescendants()
    for _, v in pairs (combinedBlockDescendants) do
        if v:IsA("TextLabel") then
            v.Text = block:GetAttribute("value")
        end
    end
end

-- Get difference (higher - lower)
--[[
local function getDifference(block_1, block_2)
    local higherValueBlock = block_1:GetAttribute("value") >= block_2:GetAttribute("value") and block_1 or block_2
    local lowerValueBlock = block_1:GetAttribute("value") < block_2:GetAttribute("value") and block_1 or block_2
    return higherValueBlock:GetAttribute("value") - lowerValueBlock:GetAttribute("value")
end
]]


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
local function twoBlocksCollisionEffects(block_1, block_2, combinedBlock, operator)
    -- tween size and position
    local targetCFrame = block_1.CFrame:Lerp(block_2.CFrame, 0.5) + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME -- CFrame of middle of two blocks
    local tweenInfo = TweenInfo.new(MathBlocksInfo.TweenInfo.Time, MathBlocksInfo.TweenInfo.EasingStyle, MathBlocksInfo.TweenInfo.EasingDirection)
    local tweenPositionSizeBlock1 = TweenService:Create(block_1, tweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = MathBlocksInfo.TweenInfo.Properties.Size, Transparency = MathBlocksInfo.TweenInfo.Properties.Transparency, Orientation = block_1.Orientation + Vector3.new(90,90,90)})
    local tweenPositionSizeBlock2 = TweenService:Create(block_2, tweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = MathBlocksInfo.TweenInfo.Properties.Size, Transparency = MathBlocksInfo.TweenInfo.Properties.Transparency, Orientation = block_2.Orientation + Vector3.new(90,90,90)})

    -- Particles
    local combineParticlesCore = MathBlocksInfo.COMBINE_PARTICLES_CORE:Clone()
    combineParticlesCore.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
    combineParticlesCore.Parent = MathBlocksInfo.EFFECTS_FOLDER
        -- Color Change Particles based on operator [No Color Change if operator == MathBlocksInfo.OPERATORS.ADD_OPERATOR]
    if operator == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR then
        for _, v in pairs (combineParticlesCore.Attachment:GetChildren()) do
            v.Color = MathBlocksInfo.COMBINE_PARTICLES_COLOR_BY_OPERATOR.SUBTRACT_OPERATOR
        end
    elseif operator == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR then
        for _, v in pairs (combineParticlesCore.Attachment:GetChildren()) do
            v.Color = MathBlocksInfo.COMBINE_PARTICLES_COLOR_BY_OPERATOR.MULTIPLY_OPERATOR
        end
    elseif operator == MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR then
        for _, v in pairs (combineParticlesCore.Attachment:GetChildren()) do
            v.Color = MathBlocksInfo.COMBINE_PARTICLES_COLOR_BY_OPERATOR.DIVIDE_OPERATOR
        end
    end

    -- Sounds
    local Sounds = combineParticlesCore.Sounds
    --Sounds.Hover_Sound_Effect:Play() -- not yet removed from Sounds
    --Sounds.Wind_2:Play()
    local turnOffEffectsCoroutine = coroutine.wrap(function()
        wait(3) -- TODO: set to static from module
        for _, v in pairs(combineParticlesCore.Attachment:GetChildren()) do
            v.Enabled = false
        end
        -- fade sound out
        local soundTweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        local soundTween = TweenService:Create(Sounds.Hover_Sound_Effect, soundTweenInfo, {Volume = 0})
        soundTween:Play()
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

        -- sound effect
        local soundName = "Light_Spell_" .. tostring(math.random(1,5))
        Sounds[soundName]:Play()

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
            Sounds.Roblox_Button_Sound_Effect:Play() -- sound effect
            conn:Disconnect()
        end)
    end)
end

local function explosionCollisionProcessing(block_1, block_2, operator)
    block_1.Anchored = true -- Prevent weird gravity interaction while tweening
    block_2.Anchored = true
    block_1.CanTouch = false -- Disallow further interaction while combining TODO: Change if model is used and not a part
    block_2.CanTouch = false

    local targetCFrame = block_1.CFrame:Lerp(block_2.CFrame, 0.5) + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
    local ExplosionInfo = MathBlocksInfo.ExplosionTweenInfo
    local explosionTweenInfo
    if operator == MathBlocksInfo.DIVIDE_BLOCK_TAG then
        explosionTweenInfo = TweenInfo.new(ExplosionInfo.Division.Time, ExplosionInfo.Division.EasingStyle, ExplosionInfo.Division.EasingDirection)
    else
        explosionTweenInfo = TweenInfo.new(ExplosionInfo.Time, ExplosionInfo.EasingStyle, ExplosionInfo.EasingDirection)
    end
    local tweenBlock1 = TweenService:Create(block_1, explosionTweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = ExplosionInfo.Properties.Size, Transparency =  ExplosionInfo.Properties.Transparency, Orientation = block_1.Orientation + ExplosionInfo.Properties.Orientation})
    local tweenBlock2 = TweenService:Create(block_2, explosionTweenInfo, {Position = targetCFrame.Position + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME, 
    Size = ExplosionInfo.Properties.Size, Transparency = ExplosionInfo.Properties.Transparency, Orientation = block_2.Orientation + ExplosionInfo.Properties.Orientation})

    -- particles
    local explosionParticlesCore 
    if operator == MathBlocksInfo.DIVIDE_BLOCK_TAG then
        explosionParticlesCore = MathBlocksInfo.EXPLOSION_PARTICLES_CORE_DIVISION:Clone()
    else
        explosionParticlesCore= MathBlocksInfo.EXPLOSION_PARTICLES_CORE:Clone()
    end
    explosionParticlesCore.CFrame = targetCFrame + MathBlocksInfo.OFFSET_OF_TARGET_CFRAME
    explosionParticlesCore.Parent = MathBlocksInfo.EFFECTS_FOLDER

    -- sounds
    local Sounds = explosionParticlesCore.Sounds
    Sounds.Hover_Sound_Effect:Play()
    Sounds.Wind_2:Play()
    local turnOffEffectsCoroutine = coroutine.wrap(function()
        if operator == MathBlocksInfo.DIVIDE_BLOCK_TAG then
            wait(MathBlocksInfo.ExplosionTweenInfo.Division.WaitDuration)
        else
            wait(3) -- TODO: set to static from module
        end
        for _, v in pairs(explosionParticlesCore.Attachment:GetChildren()) do
            v.Enabled = false
        end
        explosionParticlesCore.Sparks.Enabled = false
        -- fade sound out
        local soundTweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        local soundTween = TweenService:Create(Sounds.Hover_Sound_Effect, soundTweenInfo, {Volume = 0})
        soundTween:Play()
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
        Sounds.Explosion_sound_effect:Play()
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
        CollisionUtilities.setScreenGuis(combinedBlock)

        -- VFX
        twoBlocksCollisionEffects(block_1, block_2, combinedBlock, MathBlocksInfo.OPERATORS.ADD_OPERATOR)
    elseif operator == MathBlocksInfo.SUBTRACT_BLOCK_TAG then
        local combinedBlock = MathBlocksInfo.SUBTRACT_BLOCK:Clone()
        combinedBlock.CanTouch = false
        CollectionService:AddTag(combinedBlock, MathBlocksInfo.SUBTRACT_BLOCK_TAG)
        -- find which block has higher value
        --local newValue = getDifference(block_1, block_2)

        --combinedBlock:SetAttribute("value", newValue)
        combinedBlock:SetAttribute("value", block_1:GetAttribute("value") + block_2:GetAttribute("value"))
        if combinedBlock:GetAttribute("value") < 0 then
            combinedBlock.BrickColor = MathBlocksInfo.SUBTRACT_BLOCK_BRICKCOLOR -- indicate that number is negative
        end
        combinedBlock.Parent = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER

        -- set screenGuis
        CollisionUtilities.setScreenGuis(combinedBlock)

        -- VFX, based on operation perform different visuals
        if block_1:GetAttribute("value") < 0 or block_2:GetAttribute("value") < 0 then
            twoBlocksCollisionEffects(block_1, block_2, combinedBlock, MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR)
        else
            twoBlocksCollisionEffects(block_1, block_2, combinedBlock, MathBlocksInfo.OPERATORS.ADD_OPERATOR)
        end
    elseif operator == MathBlocksInfo.MULTIPLY_BLOCK_TAG then
        local combinedBlock = MathBlocksInfo.MULTIPLY_BLOCK:Clone()
        combinedBlock.CanTouch = false
        CollectionService:AddTag(combinedBlock, MathBlocksInfo.MULTIPLY_BLOCK_TAG)
        combinedBlock:SetAttribute("value", block_1:GetAttribute("value") * block_2:GetAttribute("value"))
        combinedBlock.Parent = MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER

        -- set screenGuis
        CollisionUtilities.setScreenGuis(combinedBlock)

        -- VFX
        twoBlocksCollisionEffects(block_1, block_2, combinedBlock, MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR)
    elseif operator == MathBlocksInfo.DIVIDE_BLOCK_TAG then
        local combinedBlock = MathBlocksInfo.DIVIDE_BLOCK:Clone()
        combinedBlock.CanTouch = false
        CollectionService:AddTag(combinedBlock, MathBlocksInfo.DIVIDE_BLOCK_TAG)
        -- divides higher by lower
        local higherValueBlock = block_1:GetAttribute("value") >= block_2:GetAttribute("value") and block_1 or block_2
        local lowerValueBlock = block_1:GetAttribute("value") < block_2:GetAttribute("value") and block_1 or block_2
        combinedBlock:SetAttribute("value", higherValueBlock:GetAttribute("value") / lowerValueBlock:GetAttribute("value"))
        combinedBlock.Parent = MathBlocksInfo.DIVIDE_BLOCKS_FOLDER

        -- set screenGuis
        CollisionUtilities.setScreenGuis(combinedBlock)

        -- VFX
        twoBlocksCollisionEffects(block_1, block_2, combinedBlock, MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR)
    end
end

function CollisionUtilities.additionCollisionProcessing(block_1, block_2)
    if not block_1:GetAttribute("operator") == MathBlocksInfo.OPERATORS.ADD_OPERATOR or not block_2:GetAttribute("operator") == MathBlocksInfo.OPERATORS.ADD_OPERATOR then
        -- TODO: Explosion for invalid operator combining
        print("Invalid")
    elseif block_1:GetAttribute("value") + block_2:GetAttribute("value") > MathBlocksInfo.ADD_LIMIT then
        explosionCollisionProcessing(block_1, block_2, MathBlocksInfo.ADD_BLOCK_TAG)
    else
        successfulCollisionProcessing(block_1, block_2, MathBlocksInfo.ADD_BLOCK_TAG)
    end
end

function CollisionUtilities.subtractionCollisionProcessing(block_1, block_2)
    --local newValue = getDifference(block_1, block_2)
    if not block_1:GetAttribute("operator") == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR or not block_2:GetAttribute("operator") == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR then
        -- TODO: Explosion for invalid operator combining
        print("Invalid")
    --elseif newValue > MathBlocksInfo.SUBTRACT_LIMIT then
    elseif block_1:GetAttribute("value") + block_2:GetAttribute("value") > MathBlocksInfo.SUBTRACT_UPPER_LIMIT or 
    block_1:GetAttribute("value") + block_2:GetAttribute("value") < MathBlocksInfo.SUBTRACT_LOWER_LIMIT then
        explosionCollisionProcessing(block_1, block_2, MathBlocksInfo.SUBTRACT_BLOCK_TAG)
    else
        successfulCollisionProcessing(block_1, block_2, MathBlocksInfo.SUBTRACT_BLOCK_TAG)
    end
end

function CollisionUtilities.multiplicationCollsionProcessing(block_1, block_2)
    if not block_1:GetAttribute("operator") == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR or not block_2:GetAttribute("operator") == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR then
        print("Invalid")
    elseif block_1:GetAttribute("value") * block_2:GetAttribute("value") > MathBlocksInfo.MULTIPLY_LIMIT then
        explosionCollisionProcessing(block_1, block_2, MathBlocksInfo.MULTIPLY_BLOCK_TAG)
    else
        successfulCollisionProcessing(block_1, block_2, MathBlocksInfo.MULTIPLY_BLOCK_TAG)
    end
end

function CollisionUtilities.divisionCollisionProcessing(block_1, block_2)
    local higherValueBlock = block_1:GetAttribute("value") >= block_2:GetAttribute("value") and block_1 or block_2
    local lowerValueBlock = block_1:GetAttribute("value") < block_2:GetAttribute("value") and block_1 or block_2
    if not block_1:GetAttribute("operator") == MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR or not block_2:GetAttribute("operator") == MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR then
        print("Invalid") -- perhaps not invalid later, for secret divide by 0 error achievement
    elseif higherValueBlock:GetAttribute("value") % lowerValueBlock:GetAttribute("value") ~= 0 then
        explosionCollisionProcessing(block_1, block_2, MathBlocksInfo.DIVIDE_BLOCK_TAG) --TODO: Special explosion for division (decimal or fraction showcase)
    else
        successfulCollisionProcessing(block_1, block_2, MathBlocksInfo.DIVIDE_BLOCK_TAG)
    end
end

return CollisionUtilities