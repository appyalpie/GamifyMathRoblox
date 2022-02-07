local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local MathBlocksInfo = require(script.Parent.Parent:WaitForChild("BlockSpawnHandler"):WaitForChild("MathBlocksInfo"))
local Timer = require(ServerScriptService.Utilities:WaitForChild("Timer"))
--[[
    
--]]

local BLOCK_DROP_PROCESSING_TEXT_1 = "processing"
local BLOCK_DROP_PROCESSING_TEXT_2 = "processing."
local BLOCK_DROP_PROCESSING_TEXT_3 = "processing.."
local BLOCK_DROP_PROCESSING_TEXT_4 = "processing..."
local BLOCK_DROP_PROCESSING_WAIT_DURATION = .3

local BLOCK_DROP_CORRECT_TEXT = "Accepted Value"
local BLOCK_DROP_REJECT_TEXT = "REJECTED"

local BlockDropUtilities = {}

-- TODO: Move setScreenGuis to a more general gui manipulation module
-- Used upon reset of the key_value of the block drop
BlockDropUtilities.setBlockDropGuis = function(guiBlock, guiText)
    local combinedBlockDescendants = guiBlock:GetDescendants()
    if guiText ~= nil then
        for _, v in pairs (combinedBlockDescendants) do
            if v:IsA("TextLabel") then
                v.Text = tostring(guiText)
            end
        end
    end
end

local function getNewKeyValue(operator)
    if operator == MathBlocksInfo.OPERATORS.ADD_OPERATOR then
        return math.random(MathBlocksInfo.ADD_KEY_VALUE_RANGE[1], MathBlocksInfo.ADD_KEY_VALUE_RANGE[2])
    elseif operator == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR then
        return math.random(MathBlocksInfo.SUBTRACT_KEY_VALUE_RANGE[1], MathBlocksInfo.SUBTRACT_KEY_VALUE_RANGE[2])
    elseif operator == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR then
        return math.random(1,10) * math.random(1,10)
        --return math.random(MathBlocksInfo.MULTIPLY_KEY_VALUE_RANGE[1], MathBlocksInfo.MUTLIPLY_KEY_VALUE_RANGE[2]) * math.random(MathBlocksInfo.MUTLIPLY_KEY_VALUE_RANGE[1], MathBlocksInfo.MUTLIPLY_KEY_VALUE_RANGE[2])
    elseif operator == MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR then
        return MathBlocksInfo.DIVIDE_KEY_VALUE[math.random(1, #MathBlocksInfo.DIVIDE_KEY_VALUE)]
    end
end

function BlockDropUtilities.correctAnswerServicing(block, operator)
    block.Anchored = true
    block.CanTouch = false

    local blockDrop
    local blockDoor
    if operator == MathBlocksInfo.OPERATORS.ADD_OPERATOR then
        blockDrop = MathBlocksInfo.ADDITION_BLOCK_DROP
        blockDoor = MathBlocksInfo.ADDITION_BLOCK_DOOR
    elseif operator == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR then
        blockDrop = MathBlocksInfo.SUBTRACTION_BLOCK_DROP
        blockDoor = MathBlocksInfo.SUBTRACTION_BLOCK_DOOR
    elseif operator == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR then
        blockDrop = MathBlocksInfo.MULTIPLICATION_BLOCK_DROP
        blockDoor = MathBlocksInfo.MULTIPLICATION_BLOCK_DOOR
    else
        blockDrop = MathBlocksInfo.DIVIDE_BLOCK_DROP
        blockDoor = MathBlocksInfo.DIVIDE_BLOCK_DOOR
    end

    local continueProcessing = true
    local processingCoroutine = coroutine.wrap(function()
        for i = 1, 30 do
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_1)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_2)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_3)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_4)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
        end
        
    end)
    processingCoroutine()
    
    local tweenInfo = TweenInfo.new(MathBlocksInfo.BlockDropTweenInfo.Time, MathBlocksInfo.BlockDropTweenInfo.EasingStyle, MathBlocksInfo.BlockDropTweenInfo.EasingDirection)
    local tweenBlock = TweenService:Create(block, tweenInfo, {Position = blockDrop.Position_Part.Position,
        Orientation = blockDrop.Position_Part.Orientation})
    tweenBlock:Play()
    local tweenCompletedConnection
    tweenCompletedConnection = tweenBlock.Completed:Connect(function()
        tweenCompletedConnection:Disconnect()
        continueProcessing = false
        BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_CORRECT_TEXT)

        -- TODO: attach beams
        local tweenInfoAccept = TweenInfo.new(MathBlocksInfo.BlockDropRejectTweenInfo.Time, MathBlocksInfo.BlockDropRejectTweenInfo.EasingStyle, 
            MathBlocksInfo.BlockDropRejectTweenInfo.EasingDirection)
        local tweenBlockAccept = TweenService:Create(block, tweenInfoAccept, { Transparency = MathBlocksInfo.BlockDropAcceptTweenInfo.Properties.Transparency,
            Position = blockDoor.Sign.Position })
        tweenBlockAccept:Play()

        local tweenAcceptCompletedConnection
        tweenAcceptCompletedConnection = tweenBlockAccept.Completed:Connect(function()
            tweenAcceptCompletedConnection:Disconnect()
            block:Destroy()
            
            -- increment lights on door
            for _, v in pairs(blockDoor.Lights:GetChildren()) do
                if v:GetAttribute("light_number") == blockDoor:GetAttribute("keys_accepted") + 1 then
                    v.BrickColor = BrickColor.new("Lime green") -- TODO: module to MathBlocks
                    break
                end
            end
            print("KA: " .. blockDoor:GetAttribute("keys_accepted") .. "   KR: " .. blockDoor:GetAttribute("keys_required"))
            if blockDoor:GetAttribute("keys_accepted") + 1 == blockDoor:GetAttribute("keys_required") then
                -- reset keys accepted and unlock door
                blockDoor:SetAttribute("keys_accepted", 0)
                -- TODO: Unlock door here
                print("DOOR IS UNLOCKED")

                -- set timer
                local doorTimer = Timer.new()
                doorTimer:start(MathBlocksInfo.DOOR_UNLOCK_DURATION, blockDrop.Timer_Block)
                TweenService:Create(blockDrop.Timer_Block, MathBlocksInfo.TIMER_BLOCK_TWEEN, {Transparency = 0}):Play()
                doorTimer.finished:Connect(function()
                    -- upon timer finishing, relock the door and reset the block drop
                    -- TODO: relock door
                    print("DOOR HAS BEEN LOCKED")
                    -- reset timer block
                    TweenService:Create(blockDrop.Timer_Block, MathBlocksInfo.TIMER_BLOCK_TWEEN, {Transparency = 1}):Play()

                    -- roll the key_value
                    local newKeyValue = getNewKeyValue(operator)
                    blockDrop:SetAttribute("key_value", newKeyValue)
                    BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, blockDrop:GetAttribute("key_value"))

                    blockDrop:SetAttribute("Servicing", false) -- reset
                    
                    -- reset door lights
                    for _, v in pairs(blockDoor.Lights:GetChildren()) do
                        v.BrickColor = BrickColor.new("Really red") --TODO: module to MathBlocks
                    end
                end)
            else
                blockDoor:SetAttribute("keys_accepted", blockDoor:GetAttribute("keys_accepted") + 1)

                -- roll the key_value
                local newKeyValue = getNewKeyValue(operator)
                blockDrop:SetAttribute("key_value", newKeyValue)
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, blockDrop:GetAttribute("key_value"))

                blockDrop:SetAttribute("Servicing", false) -- reset
            end
        end)
    end)
end

function BlockDropUtilities.rejectAnswerServicing(block, operator)
    block.Anchored = true
    block.CanTouch = false

    local blockDrop
    if operator == MathBlocksInfo.OPERATORS.ADD_OPERATOR then
        blockDrop = MathBlocksInfo.ADDITION_BLOCK_DROP
    elseif operator == MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR then
        blockDrop = MathBlocksInfo.SUBTRACTION_BLOCK_DROP
    elseif operator == MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR then
        blockDrop = MathBlocksInfo.MULTIPLICATION_BLOCK_DROP
    else
        blockDrop = MathBlocksInfo.DIVIDE_BLOCK_DROP
    end

    local continueProcessing = true
    local processingCoroutine = coroutine.wrap(function()
        for i = 1, 30 do
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_1)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_2)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_3)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
            if continueProcessing then
                BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_PROCESSING_TEXT_4)
            else 
                break
            end
            wait(BLOCK_DROP_PROCESSING_WAIT_DURATION)
        end
        
    end)
    processingCoroutine()
    
    -- tween the block to
    local tweenInfo = TweenInfo.new(MathBlocksInfo.BlockDropTweenInfo.Time, MathBlocksInfo.BlockDropTweenInfo.EasingStyle, MathBlocksInfo.BlockDropTweenInfo.EasingDirection)
    local tweenBlock = TweenService:Create(block, tweenInfo, {Position = blockDrop.Position_Part.Position,
        Orientation = blockDrop.Position_Part.Orientation})
    tweenBlock:Play()
    local tweenCompletedConnection
    tweenCompletedConnection = tweenBlock.Completed:Connect(function()
        tweenCompletedConnection:Disconnect()
        continueProcessing = false
        BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, BLOCK_DROP_REJECT_TEXT)
        -- TODO: attach beams
        local tweenInfoReject = TweenInfo.new(MathBlocksInfo.BlockDropRejectTweenInfo.Time, MathBlocksInfo.BlockDropRejectTweenInfo.EasingStyle, 
            MathBlocksInfo.BlockDropRejectTweenInfo.EasingDirection)
        local tweenBlockReject = TweenService:Create(block, tweenInfoReject, { Transparency = MathBlocksInfo.BlockDropRejectTweenInfo.Properties.Transparency })
        tweenBlockReject:Play()
        local tweenRejectCompletedConnection
        tweenRejectCompletedConnection = tweenBlockReject.Completed:Connect(function()
            tweenRejectCompletedConnection:Disconnect()
            block:Destroy()
            BlockDropUtilities.setBlockDropGuis(blockDrop.Key_Value_Guis, blockDrop:GetAttribute("key_value"))
            blockDrop:SetAttribute("Servicing", false) -- reset
        end)
    end)
end

BlockDropUtilities.setBlockDropGuis(MathBlocksInfo.ADDITION_BLOCK_DROP.Key_Value_Guis, MathBlocksInfo.ADDITION_BLOCK_DROP:GetAttribute("key_value"))
BlockDropUtilities.setBlockDropGuis(MathBlocksInfo.SUBTRACTION_BLOCK_DROP.Key_Value_Guis, MathBlocksInfo.SUBTRACTION_BLOCK_DROP:GetAttribute("key_value"))
BlockDropUtilities.setBlockDropGuis(MathBlocksInfo.MULTIPLICATION_BLOCK_DROP.Key_Value_Guis, MathBlocksInfo.MULTIPLICATION_BLOCK_DROP:GetAttribute("key_value"))
BlockDropUtilities.setBlockDropGuis(MathBlocksInfo.DIVIDE_BLOCK_DROP.Key_Value_Guis, MathBlocksInfo.DIVIDE_BLOCK_DROP:GetAttribute("key_value"))

return BlockDropUtilities