--[[
    BlockSpawnHandler handles the initialization of spawning blocks. Attaches appropriate functions to events and initializes tags.
--]]

local CollectionService = game:GetService("CollectionService") -- for tags
local ServerStorage = game:GetService("ServerStorage") -- for blocks

local CollisionUtilities = require(script:WaitForChild("CollisionUtilities")) -- module to handle collision VFX and logic
local MathBlocksInfo = require(script:WaitForChild("MathBlocksInfo")) -- Information on Math_Blocks Game Settings

--[[
    CollectionService Tag Added Signals
--]]
local ADD_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(MathBlocksInfo.ADD_BLOCK_TAG)
local SUBTRACT_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(MathBlocksInfo.SUBTRACT_BLOCK_TAG)
local MULTIPLY_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(MathBlocksInfo.MULTIPLY_BLOCK_TAG)
--local DIVIDE_BLOCK_TAGGED_SIGNAL = CollectionService:GetInstanceAddedSignal(DIVIDE_BLOCK_TAG)

ADD_BLOCK_TAGGED_SIGNAL:Connect(function(newAddBlock)
    print("ADD BLOCK HAS BEEN ADDED")
    newAddBlock.Touched:Connect(function(objectHit)
        if not newAddBlock:GetAttribute("Touched") and not objectHit:GetAttribute("Touched") then -- newAddBlock has attribute "Touched" (Boolean) for debounce
            if objectHit:IsA("Part") then -- TODO: better logic for models + logic for if objectHit is combinable
                if objectHit:GetAttribute("value") ~= nil then

                    objectHit:SetAttribute("Touched", true) -- prevent further touches
                    newAddBlock:SetAttribute("Touched", true)
                    CollisionUtilities.additionCollisionProcessing(newAddBlock, objectHit) -- collision processing
                end -- end check if objectHas attribute "value"
            end -- end check if hit Part
        end -- end check if self is already "Touched"
    end)
end)
SUBTRACT_BLOCK_TAGGED_SIGNAL:Connect(function(newSubtractBlock)
    print("SUBTRACT BLOCK HAS BEEN ADDED")
    newSubtractBlock.Touched:Connect(function(objectHit)
        if not newSubtractBlock:GetAttribute("Touched") and not objectHit:GetAttribute("Touched") then
            if objectHit:IsA("Part") then
                if objectHit:GetAttribute("value") ~= nil then
                    objectHit:SetAttribute("Touched", true)
                    newSubtractBlock:SetAttribute("Touched", true)
                    CollisionUtilities.subtractionCollisionProcessing(newSubtractBlock, objectHit)
                end
            end
        end
    end)
end)
MULTIPLY_BLOCK_TAGGED_SIGNAL:Connect(function(newMultiplyBlock)
    print("MULTIPLY BLOCK HAS BEEN ADDED")
    newMultiplyBlock.Touched:Connect(function(objectHit)
        if not newMultiplyBlock:GetAttribute("Touched") and not objectHit:GetAttribute("Touched") then
            if objectHit:IsA("Part") then
                if objectHit:GetAttribute("value") ~= nil then
                    objectHit:SetAttribute("Touched", true)
                    newMultiplyBlock:SetAttribute("Touched", true)
                    CollisionUtilities.multiplicationCollsionProcessing(newMultiplyBlock, objectHit)
                end
            end
        end
    end)
end)
--DIVIDE_BLOCK_TAGGED_SIGNAL

--[[
    Set Event on Block Destroyed/Removed from Game to spawn an additional one back in.
--]]
local function onChildRemovedFromAddBlocksFolder()
    local children = MathBlocksInfo.ADD_BLOCKS_FOLDER:GetChildren()
    local childrenCount = #children
    local numberOfBlocksToSpawn = MathBlocksInfo.ADD_BLOCKS_FOLDER:GetAttribute("capacity") - childrenCount
    for i = 1, numberOfBlocksToSpawn do
        --TODO: Revamp Spawning with spawn utilities module (VFX, SFX)
        local newAddBlock = MathBlocksInfo.ADD_BLOCK:Clone() -- Clone from ServerStorage
        CollectionService:AddTag(newAddBlock, MathBlocksInfo.ADD_BLOCK_TAG) -- Give logic
        newAddBlock.Parent = MathBlocksInfo.ADD_BLOCKS_FOLDER
        newAddBlock.Position = MathBlocksInfo.ADD_BLOCKS_FOLDER:GetAttribute("position") + 
            Vector3.new(math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH), 0, math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH))
    end
end

--[[
    Ensures a balance of positive and negative subtract blocks in the subtract blocks island
    0 blocks are currently not counted toward the count.
--]]
local function onChildRemovedFromSubtractBlocksFolder()
    local children = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER:GetChildren()
    local positiveChildrenCount, negativeChildrenCount = 0, 0
    for _, v in pairs(children) do
        if v:GetAttribute("value") > 0 then
            positiveChildrenCount = positiveChildrenCount + 1
        elseif v:GetAttribute("value") < 0 then
            negativeChildrenCount = negativeChildrenCount + 1
        end
    end
    local numberOfPositiveBlocksToSpawn = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER:GetAttribute("positive_capacity") - positiveChildrenCount
    local numberOfNegativeBlocksToSpawn = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER:GetAttribute("negative_capacity") - negativeChildrenCount
    for i = 1, numberOfPositiveBlocksToSpawn do
        local newSubtractBlock = MathBlocksInfo.SUBTRACT_BLOCK:Clone()
        newSubtractBlock:SetAttribute("value", 1)
        CollisionUtilities.setScreenGuis(newSubtractBlock)
        CollectionService:AddTag(newSubtractBlock, MathBlocksInfo.SUBTRACT_BLOCK_TAG)
        newSubtractBlock.Parent = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER
        newSubtractBlock.Position = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER:GetAttribute("position") + 
            Vector3.new(math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH), 0, math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH))
    end
    for i = 1, numberOfNegativeBlocksToSpawn do
        local newSubtractBlock = MathBlocksInfo.SUBTRACT_BLOCK:Clone()
        newSubtractBlock:SetAttribute("value", -1)
        newSubtractBlock.BrickColor = BrickColor.new("Pastel Blue") -- indicate that number is negative
        CollisionUtilities.setScreenGuis(newSubtractBlock)
        CollectionService:AddTag(newSubtractBlock, MathBlocksInfo.SUBTRACT_BLOCK_TAG)
        newSubtractBlock.Parent = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER
        newSubtractBlock.Position = MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER:GetAttribute("position") + 
            Vector3.new(math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH), 0, math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH))
    end
end

--[[
    TODO: Balance value of blocks based on key value, for now, spawns in random number from 1 - 9
--]]
local function onChildRemovedFromMultiplyBlocksFolder()
    local children = MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER:GetChildren()
    local childrenCount = #children
    local numberOfBlocksToSpawn = MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER:GetAttribute("capacity") - childrenCount
    for i = 1, numberOfBlocksToSpawn do
        --TODO: Revamp Spawning with spawn utilities module (VFX, SFX)
        local newMultiplyBlock = MathBlocksInfo.MULTIPLY_BLOCK:Clone()
        CollectionService:AddTag(newMultiplyBlock, MathBlocksInfo.MULTIPLY_BLOCK_TAG)

        newMultiplyBlock:SetAttribute("value", math.random(1,9)) -- TODO: Change to balance based on key value
        CollisionUtilities.setScreenGuis(newMultiplyBlock)
        
        newMultiplyBlock.Parent = MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER
        newMultiplyBlock.Position = MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER:GetAttribute("position") + 
            Vector3.new(math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH), 0, math.random(MathBlocksInfo.SPAWN_AREA_LOW, MathBlocksInfo.SPAWN_AREA_HIGH))
    end
end
--local function onChildRemovedFromDivideBlocksFolder()

MathBlocksInfo.ADD_BLOCKS_FOLDER.ChildRemoved:Connect(onChildRemovedFromAddBlocksFolder)
MathBlocksInfo.SUBTRACT_BLOCKS_FOLDER.ChildRemoved:Connect(onChildRemovedFromSubtractBlocksFolder)
MathBlocksInfo.MULTIPLY_BLOCKS_FOLDER.ChildRemoved:Connect(onChildRemovedFromMultiplyBlocksFolder)

onChildRemovedFromAddBlocksFolder() -- for testing
onChildRemovedFromSubtractBlocksFolder() -- for testing
onChildRemovedFromMultiplyBlocksFolder() -- for testing...