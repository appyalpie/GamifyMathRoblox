--[[
    to apply script make sure the target Blocks are named OceanBlock
]]

local OceanBlock = {}
--OceanBlock traits 
OceanBlock.__index = OceanBlock
OceanBlock.TAG_NAME = "Ocean"
OceanBlock.ANTI_GRAVITY = .5
OceanBlock.CanCollide = false



local CollectionService = game:GetService("CollectionService")
-- local tweenService = game:GetService("TweenService") will be used later to adjust fall rate
local Block = workspace.OceanBlock
CollectionService:AddTag(Block,"Ocean")

function OceanBlock.new(Ocean)
    local self = {}
    setmetatable(self,OceanBlock)
    self.Ocean = Ocean
    self.debounce = false
    self.touchConn = Ocean.Touched:Connect(function(instance)
    self:onTouch(instance)
    end)
    self:KillPlayer(false)
    return self
end


function OceanBlock:onTouch(part)
    if self.debounce then 
        return 
    end
    local human = part.Parent:FindFirstChild("Humanoid")

    if not human then 
        return 
    end
    local bf = Instance.new("BodyForce")
    -- slows falling when in water
    bf.Force = Vector3.new(0, workspace.Gravity * part:GetMass() * OceanBlock.ANTI_GRAVITY, 0)
    bf.Parent = part.Parent -- player
    -- checks if player is in free fall in ocean to help with future idea of non death areas in ocean
    if human:GetState() == Enum.HumanoidStateType.Freefall then
        wait(3) -- saftey check for freefall
        if human:GetState() == Enum.HumanoidStateType.Freefall then
        human.Health = 0
        end
    end
    
end
function OceanBlock:Cleanup()
    self.touchConn:disconnect()
    self.touchConn = nil
end

local OceanBlockAddedSignal = CollectionService:GetInstanceAddedSignal(OceanBlock.TAG_NAME)
local OceanBlockRemovedSignal = CollectionService:GetInstanceRemovedSignal(OceanBlock.TAG_NAME)

local OceanBlocks = {}
local function onOceanBlockAdded(Ocean)
    if Ocean:IsA("BasePart") then
        OceanBlocks[Ocean] = OceanBlock.new(Ocean)
    end
end
local function onOceanBlockRemoved(Ocean)
    if OceanBlocks[Ocean] then
        OceanBlocks[Ocean]:cleanup()
        OceanBlocks[Ocean] = nil
    end
end
for _,inst in pairs(CollectionService:GetTagged(OceanBlock.TAG_NAME)) do
    onOceanBlockAdded(inst)
end
OceanBlockAddedSignal:Conncect(onOceanBlockAdded)
OceanBlockRemovedSignal:Connect(onOceanBlockRemoved)

