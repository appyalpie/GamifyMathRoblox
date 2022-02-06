local ServerStorage = game:GetService("ServerStorage")

local ADD_BLOCK = ServerStorage.Island_1.Math_Blocks.Add_Block
local SUBTRACT_BLOCK = ServerStorage.Island_1.Math_Blocks.Subtract_Block
local MULTIPLY_BLOCK = ServerStorage.Island_1.Math_Blocks.Multiply_Block
local DIVIDE_BLOCK = ServerStorage.Island_1.Math_Blocks.Divide_Block

local ADD_LIMIT = 5
local SUBTRACT_UPPER_LIMIT = 5
local SUBTRACT_LOWER_LIMIT = -5
local MULTIPLY_LIMIT = 100

local ADD_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Add_Blocks
local SUBTRACT_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Subtract_Blocks
local MULTIPLY_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Multiply_Blocks
local DIVIDE_BLOCKS_FOLDER = game.Workspace.Island_1.Math_Blocks.Divide_Blocks

-- Static Tag Listings
local ADD_BLOCK_TAG = "Add_Block"
local SUBTRACT_BLOCK_TAG = "Subtract_Block"
local MULTIPLY_BLOCK_TAG = "Multiply_Block"
local DIVIDE_BLOCK_TAG = "Divide_Block"

local COMBINE_PARTICLES_CORE = ServerStorage.Island_1.Math_Blocks.Particles.Combine_Particles_Core
local EXPLOSION_PARTICLES_CORE = ServerStorage.Island_1.Math_Blocks.Particles.Explosion_Particles_Core
local EXPLOSION_PARTICLES_CORE_DIVISION = ServerStorage.Island_1.Math_Blocks.Particles.Explosion_Particles_Core_Division

local EFFECTS_FOLDER = game.Workspace.Island_1.Math_Blocks.Effects

local BLOCK_DROPS_FOLDER = game.Workspace.Island_1.Math_Blocks.Block_Drops
local DIVIDE_BLOCK_DROP = BLOCK_DROPS_FOLDER.Divide_Block_Drop

local MathBlocksInfo = {}

MathBlocksInfo.OPERATORS = {
    ADD_OPERATOR = "add",
    SUBTRACT_OPERATOR = "subtract",
    MULTIPLY_OPERATOR = "multiply",
    DIVIDE_OPERATOR = "divide"
}

MathBlocksInfo.ADD_BLOCK = ADD_BLOCK
MathBlocksInfo.ADD_LIMIT = ADD_LIMIT
MathBlocksInfo.ADD_BLOCK_TAG = ADD_BLOCK_TAG
MathBlocksInfo.ADD_BLOCKS_FOLDER = ADD_BLOCKS_FOLDER

MathBlocksInfo.SUBTRACT_BLOCK = SUBTRACT_BLOCK
MathBlocksInfo.SUBTRACT_UPPER_LIMIT = SUBTRACT_UPPER_LIMIT
MathBlocksInfo.SUBTRACT_LOWER_LIMIT = SUBTRACT_LOWER_LIMIT
MathBlocksInfo.SUBTRACT_BLOCK_TAG = SUBTRACT_BLOCK_TAG
MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER = SUBTRACT_BLOCKS_FOLDER

MathBlocksInfo.MULTIPLY_BLOCK = MULTIPLY_BLOCK
MathBlocksInfo.MULTIPLY_LIMIT = MULTIPLY_LIMIT
MathBlocksInfo.MULTIPLY_BLOCK_TAG = MULTIPLY_BLOCK_TAG
MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER = MULTIPLY_BLOCKS_FOLDER

MathBlocksInfo.DIVIDE_BLOCK = DIVIDE_BLOCK
MathBlocksInfo.DIVIDE_BLOCK_TAG = DIVIDE_BLOCK_TAG
MathBlocksInfo.DIVIDE_BLOCKS_FOLDER = DIVIDE_BLOCKS_FOLDER
MathBlocksInfo.DIVIDE_BLOCKS_DIVISORS = { 2, 3, 5, 7 }
MathBlocksInfo.DIVIDE_BLOCK_DROP = DIVIDE_BLOCK_DROP
MathBlocksInfo.DIVIDE_KEY_MULTIPLIERS = { 5, 6, 7, 8 }

MathBlocksInfo.ADD_BLOCK_BRICKCOLOR = BrickColor.new("Pastel yellow")
MathBlocksInfo.SUBTRACT_BLOCK_BRICKCOLOR = BrickColor.new("Pastel Blue")
MathBlocksInfo.MULTIPLY_BLOCK_BRICKCOLOR = BrickColor.new("Medium red")
MathBlocksInfo.DIVIDE_BLOCK_BRICKCOLOR = BrickColor.new("Pastel green")

MathBlocksInfo.COMBINE_PARTICLES_CORE = COMBINE_PARTICLES_CORE
MathBlocksInfo.EXPLOSION_PARTICLES_CORE = EXPLOSION_PARTICLES_CORE
MathBlocksInfo.EXPLOSION_PARTICLES_CORE_DIVISION = EXPLOSION_PARTICLES_CORE_DIVISION
MathBlocksInfo.EFFECTS_FOLDER = EFFECTS_FOLDER

MathBlocksInfo.COMBINE_PARTICLES_COLOR_BY_OPERATOR = {
    ADD_OPERATOR = nil,
    SUBTRACT_OPERATOR = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0, .33, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0, .33, 1))
    },
    MULTIPLY_OPERATOR = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(.66, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(.66, 0, 0))
    },
    DIVIDE_OPERATOR = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(.33, 1, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(.33, 1, 0))
    }
}

MathBlocksInfo.OFFSET_OF_TARGET_CFRAME = Vector3.new(0, 3, 0)

MathBlocksInfo.SPAWN_AREA_LOW = -50
MathBlocksInfo.SPAWN_AREA_HIGH = 50

MathBlocksInfo.TweenInfo = {
    Time = 2,
    EasingStyle = Enum.EasingStyle.Cubic,
    EasingDirection = Enum.EasingDirection.In,
    Properties = {
        Size = Vector3.new(0,0,0),
        Transparency = .7
    }
}

MathBlocksInfo.ExplosionTweenInfo = {
    Division = {
        Time = 1.5,
        EasingStyle = Enum.EasingStyle.Linear,
        EasingDirection = Enum.EasingDirection.In,
        WaitDuration = 2
    },
    Time = 2,
    EasingStyle = Enum.EasingStyle.Elastic,
    EasingDirection = Enum.EasingDirection.In,
    Properties = {
        Size = Vector3.new(0,0,0),
        Transparency = .5,
        Orientation = Vector3.new(90,90,90)
    }
}

MathBlocksInfo.NewBlockInfo = {
    Size = Vector3.new(5,5,5),
    Transparency = 0,
}

--[[
MathBlocksInfo.AngularVelocityInfo = {
    MaxTorque = 99999,
    AngularVelocity = Vector3.new(1,3,2)
}
]]

MathBlocksInfo.AttachmentInfo = {
    Position = Vector3.new(2,0,2)
}

return MathBlocksInfo