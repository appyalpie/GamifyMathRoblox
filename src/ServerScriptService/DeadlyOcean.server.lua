--[[
    to apply script make sure the target Blocks are named OceanBlock and 
    Collide is disabled in workspace
]]
--OceanBlock traits 
local OceanBlock = {}
OceanBlock.__index = OceanBlock
OceanBlock.TAG_NAME = "Ocean"


local CollectionService = game:GetService("CollectionService")

-- adds Ocean tag to blocks named OceanBlock
local Block = workspace.OceanAssets.OceanBlock
CollectionService:AddTag(Block,"Ocean")

-- is meant to initilize the OceanBlock table

function OceanBlock.new(Ocean)
    local self = {}
    setmetatable(self,OceanBlock)
    self.Ocean = Ocean
        self.touchConn = Ocean.Touched:Connect(function(...)
        self:onTouch(...)
        end)
    return self
end

--[[
    Ocean tagged blocks Kills player on touch
]]

function OceanBlock:onTouch(part)
    local human = part.Parent:FindFirstChild("Humanoid")
    if not human then 
        return 
    end
        human.Health = 0    
end

-- shows up as the cleanup to prevent memory loss inside the API documentation

function OceanBlock:Cleanup()
    self.touchConn:Disconnect()
    self.touchConn = nil
end

--[[
   is meant to Call the startup and cleanup of block tags based on what i could find from
    API documentation and tutorials so far
]]

local OceanBlocks = {}

--indexes blocks in the collection service table

local function onOceanBlockAdded(Ocean)
    if Ocean:IsA("Part") then
        OceanBlocks[Ocean] = OceanBlock.new(Ocean)
    end
end
-- use this to get tagged blocks look above on how to add tags to untagged blocks
for _,inst in pairs(CollectionService:GetTagged(OceanBlock.TAG_NAME)) do
    onOceanBlockAdded(inst)
end


