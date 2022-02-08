local MathBlocksInfo = require(script.Parent:WaitForChild("BlockSpawnHandler"):WaitForChild("MathBlocksInfo"))
local BlockDropUtilities = require(script.BlockDropUtilities)
-- generation of keys will differ for each section of the island

--[[
    Addition:
    Subtraction:
    Multiplication:
    Division:
--]]

-- Heirarchy of Block_Drop -> Model -> (Part) Position_Part, (Part) Block_Drop_Part, (Part) Beam_Part
--MathBlocksInfo.DIVIDE_BLOCK_DROP
--[[
    If the object hit is a block and has a value...
--]]
MathBlocksInfo.ADDITION_BLOCK_DROP.Block_Drop_Part.Touched:Connect(function(objectHit)
    if not MathBlocksInfo.ADDITION_BLOCK_DROP:GetAttribute("Servicing") and not objectHit:GetAttribute("Touched") then
        if objectHit:IsA("Part") then
            if objectHit:GetAttribute("value") ~= nil then
                -- correct answer
                if objectHit:GetAttribute("value") == MathBlocksInfo.ADDITION_BLOCK_DROP:GetAttribute("key_value") then
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.ADDITION_BLOCK_DROP:SetAttribute("Servicing", true) -- debounce, can only service one at a time
                    BlockDropUtilities.correctAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.ADD_OPERATOR)
                else --incorrect answer
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.ADDITION_BLOCK_DROP:SetAttribute("Servicing", true)
                    BlockDropUtilities.rejectAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.ADD_OPERATOR)
                end
            end
        end
    end
end)

MathBlocksInfo.SUBTRACTION_BLOCK_DROP.Block_Drop_Part.Touched:Connect(function(objectHit)
    if not MathBlocksInfo.SUBTRACTION_BLOCK_DROP:GetAttribute("Servicing") and not objectHit:GetAttribute("Touched") then
        if objectHit:IsA("Part") then
            if objectHit:GetAttribute("value") ~= nil then
                -- correct answer
                if objectHit:GetAttribute("value") == MathBlocksInfo.SUBTRACTION_BLOCK_DROP:GetAttribute("key_value") then
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.SUBTRACTION_BLOCK_DROP:SetAttribute("Servicing", true) -- debounce, can only service one at a time
                    BlockDropUtilities.correctAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR)
                else --incorrect answer
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.SUBTRACTION_BLOCK_DROP:SetAttribute("Servicing", true)
                    BlockDropUtilities.rejectAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.SUBTRACT_OPERATOR)
                end
            end
        end
    end
end)

MathBlocksInfo.MULTIPLICATION_BLOCK_DROP.Block_Drop_Part.Touched:Connect(function(objectHit)
    if not MathBlocksInfo.MULTIPLICATION_BLOCK_DROP:GetAttribute("Servicing") and not objectHit:GetAttribute("Touched") then
        if objectHit:IsA("Part") then
            if objectHit:GetAttribute("value") ~= nil then
                -- correct answer
                if objectHit:GetAttribute("value") == MathBlocksInfo.MULTIPLICATION_BLOCK_DROP:GetAttribute("key_value") then
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.MULTIPLICATION_BLOCK_DROP:SetAttribute("Servicing", true) -- debounce, can only service one at a time
                    BlockDropUtilities.correctAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR)
                else --incorrect answer
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.MULTIPLICATION_BLOCK_DROP:SetAttribute("Servicing", true)
                    BlockDropUtilities.rejectAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.MULTIPLY_OPERATOR)
                end
            end
        end
    end
end)

MathBlocksInfo.DIVIDE_BLOCK_DROP.Block_Drop_Part.Touched:Connect(function(objectHit)
    if not MathBlocksInfo.DIVIDE_BLOCK_DROP:GetAttribute("Servicing") and not objectHit:GetAttribute("Touched") then
        if objectHit:IsA("Part") then
            if objectHit:GetAttribute("value") ~= nil then
                -- correct answer
                if objectHit:GetAttribute("value") == MathBlocksInfo.DIVIDE_BLOCK_DROP:GetAttribute("key_value") then
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.DIVIDE_BLOCK_DROP:SetAttribute("Servicing", true) -- debounce, can only service one at a time
                    BlockDropUtilities.correctAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR)
                else --incorrect answer
                    objectHit:SetAttribute("Touched", true)
                    MathBlocksInfo.DIVIDE_BLOCK_DROP:SetAttribute("Servicing", true)
                    BlockDropUtilities.rejectAnswerServicing(objectHit, MathBlocksInfo.OPERATORS.DIVIDE_OPERATOR)
                end
            end
        end
    end
end)