local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local ADD_BLOCK = ServerStorage.Island_1.Math_Blocks.Add_Block
--local SUB_BLOCK
--local MUL_BLOCK
--local DIV_BLOCK

local ADD_LIMIT = 20

local ADD_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Add_Blocks
--local SUBTRACT_BLOCKS_FOLDER
--local MULTIPLY_BLOCKS_FOLDER
--local DIVIDE_BLOCKS_FOLDER

-- Static Tag Listings
local ADD_BLOCK_TAG = "Add_Block"
local SUBTRACT_BLOCK_TAG = "Subtract_Block"
local MULTIPLY_BLOCK_TAG = "Multiply_Block"
local DIVIDE_BLOCK_TAG = "Divide_Block"

local COMBINE_PARTICLES_CORE = ServerStorage.Island_1.Math_Blocks.Particles.Combine_Particles_Core

local EFFECTS_FOLDER = game.Workspace.Island_1.Math_Blocks.Effects

local MathBlocksInfo = {}

MathBlocksInfo.ADD_BLOCK = ADD_BLOCK
MathBlocksInfo.ADD_LIMIT = ADD_LIMIT
MathBlocksInfo.ADD_BLOCK_TAG = ADD_BLOCK_TAG
MathBlocksInfo.ADD_BLOCKS_FOLDER = ADD_BLOCKS_FOLDER

MathBlocksInfo.COMBINE_PARTICLES_CORE = COMBINE_PARTICLES_CORE
MathBlocksInfo.EFFECTS_FOLDER = EFFECTS_FOLDER

MathBlocksInfo.OFFSET_OF_TARGET_CFRAME = Vector3.new(0, 3, 0)

MathBlocksInfo.TweenInfo = {
    Time = 2,
    EasingStyle = Enum.EasingStyle.Cubic,
    EasingDirection = Enum.EasingDirection.In,
    Properties = {
        Size = Vector3.new(0,0,0),
        Transparency = .7
    }
}

MathBlocksInfo.NewBlockInfo = {
    Size = Vector3.new(5,5,5),
    Transparency = 0,
}

MathBlocksInfo.AngularVelocityInfo = {
    MaxTorque = 99999,
    AngularVelocity = Vector3.new(1,3,2)
}

MathBlocksInfo.AttachmentInfo = {
    Position = Vector3.new(2,0,2)
}

return MathBlocksInfo