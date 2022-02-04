local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local ADD_BLOCK = ServerStorage.Island_1.Math_Blocks.Add_Block
--local SUB_BLOCK
--local MUL_BLOCK
--local DIV_BLOCK

local ADD_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Add_Blocks
--local ADD_BLOCKS_FOLDER
--local ADD_BLOCKS_FOLDER
--local ADD_BLOCKS_FOLDER

-- Static Tag Listings
local ADD_BLOCK_TAG = "Add_Block"
local SUBTRACT_BLOCK_TAG = "Subtract_Block"
local MULTIPLY_BLOCK_TAG = "Multiply_Block"
local DIVIDE_BLOCK_TAG = "Divide_Block"

local CollisionUtilities = {}

function CollisionUtilities.additionCollisionProcessing(block_1, block_2)
    if not block_1:GetAttribute("operator") == "add" or not block_2:GetAttribute("operator") == "add" then
        -- TODO: Explosion for invalid operator combining
        print("Invalid")
    else
        block_1.CanTouch = false -- Disallow further interactoin while combining TODO: Change if model is used and not a part
        block_2.CanTouch = false
        -- TODO: Add VFX (Tween Size, Rotation and CFrame of both blocks)
        local combinedBlock = ADD_BLOCK:Clone()
        CollectionService:AddTag(combinedBlock, ADD_BLOCK_TAG)
        combinedBlock:SetAttribute("value", block_1:GetAttribute("value") + block_2:GetAttribute("value"))
        combinedBlock.Parent = ADD_BLOCKS_FOLDER
        combinedBlock.CFrame = block_1.CFrame:Lerp(block_2.CFrame, 0.5)
        block_1:Destroy()
        block_2:Destroy()
    end
end

return CollisionUtilities