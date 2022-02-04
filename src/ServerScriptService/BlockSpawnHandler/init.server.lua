--[[
    BlockSpawnHandler handles the initialization of spawning blocks. Attaches appropriate functions to events and initializes tags.
--]]

local CollectionService = game:GetService("CollectionService") -- for tags
local ServerStorage = game:GetService("ServerStorage") -- for blocks

local CollisionUtilities = require(script:WaitForChild("CollisionUtilities")) -- module to handle collision VFX and logic

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

--[[
    CollectionService Tag Added Signals
--]]
local ADD_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(ADD_BLOCK_TAG)
local SUBTRACT_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(SUBTRACT_BLOCK_TAG)
local MULTIPLY_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(MULTIPLY_BLOCK_TAG)
local DIVIDE_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(DIVIDE_BLOCK_TAG)

ADD_BLOCK_TAGGED_SIGNAL:Connect(function(newAddBlock)
    print("ADD BLOCK HAS BEEN ADDED")
    newAddBlock.Touched:Connect(function(objectHit)
        if not newAddBlock:GetAttribute("Touched") then -- newAddBlock has attribute "Touched" (Boolean) for debounce
            if objectHit:IsA("Part") then -- TODO: better logic for models + logic for if objectHit is combinable
                if objectHit:GetAttribute("value") ~= nil then

                    objectHit:SetAttribute("Touched", true) -- prevent further touches
                    CollisionUtilities.additionCollisionProcessing(newAddBlock, objectHit) -- collision processing
                end -- end check if objectHas attribute "value"
            end -- end check if hit Part
        end -- end check if self is already "Touched"
    end)
end)
--SUBTRACT_BLOCK_TAGGED_SIGNAL
--MULTIPLY_BLOCK_TAGGED_SIGNAL
--DIVIDE_BLOCK_TAGGED_SIGNAL

--[[
    Set Event on Block Destroyed/Removed from Game to spawn an additional one back in.
--]]
local function onChildRemovedFromAddBlocksFolder()
    local children = ADD_BLOCKS_FOLDER:GetChildren()
    local childrenCount = #children
    local numberOfBlocksToSpawn = ADD_BLOCKS_FOLDER:GetAttribute("capacity") - childrenCount
    for i = 1, numberOfBlocksToSpawn do
        --TODO: Revamp Spawning with spawn utilities module (VFX, SFX)
        local newAddBlock = ADD_BLOCK:Clone() -- Clone from ServerStorage
        CollectionService:AddTag(newAddBlock, ADD_BLOCK_TAG) -- Give logic
        newAddBlock.Parent = ADD_BLOCKS_FOLDER
        newAddBlock.Position = ADD_BLOCKS_FOLDER:GetAttribute("position") + Vector3.new(math.random(-25, 25), 0, math.random(-10, 10))
    end
end
--local function onChildRemovedFromSubtractBlocksFolder()
--local function onChildRemovedFromMultiplyBlocksFolder()
--local function onChildRemovedFromDivideBlocksFolder()

ADD_BLOCKS_FOLDER.ChildRemoved:Connect(onChildRemovedFromAddBlocksFolder)

onChildRemovedFromAddBlocksFolder() -- for testing