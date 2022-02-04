--[[
    to apply script make sure the target Blocks are named OceanBlock and 
    Collide is disabled in workspace
]]
--OceanBlock traits 

local OceanBlock = {}
OceanBlock.__index = OceanBlock
OceanBlock.TAG_NAME = "Ocean"
OceanBlock.ANTI_GRAVITY = .5

local CollectionService = game:GetService("CollectionService")

-- local tweenService = game:GetService("TweenService") will be used later to adjust fall rate

local Block = workspace.OceanBlock
CollectionService:AddTag(Block,"Ocean")

-- is meant to initilize the OceanBlock table

function OceanBlock.new(Ocean)
    local self = {}
    setmetatable(self,OceanBlock)
    self.Ocean = Ocean
        self.touchConn = Ocean.Touched:Connect(function(...)
        self:onTouch(...)
        end)
    --self:KillPlayer(false)
    return self
end

--[[
    Starts a timer once a player touches the ocean blocks checks if in Freefall as 
well as is suppose to slow falling speed and kill players if still falling after timer
]]

function OceanBlock:onTouch(part)
    local human = part.Parent:FindFirstChild("Humanoid")
    if not human then 
        return 
    end
    local bf = Instance.new("BodyForce")

    -- slows falling when in water
    -- antigravity effect may need adjustments on
    bf.Force = Vector3.new(0, workspace.Gravity * part:GetMass() * OceanBlock.ANTI_GRAVITY, 0)
    bf.Parent = part.Parent

    -- checks if player is in free fall in ocean to help with future idea of non death areas in ocean

    if human:GetState() == Enum.HumanoidStateType.Freefall then
        wait(3) -- saftey check for freefall
        if human:GetState() == Enum.HumanoidStateType.Freefall then
        human.Health = 0
        end
    end
    
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


local function onOceanBlockAdded(Ocean)
    if Ocean:IsA("Part") then
        OceanBlocks[Ocean] = OceanBlock.new(Ocean)
    end
end
for _,inst in pairs(CollectionService:GetTagged(OceanBlock.TAG_NAME)) do
    onOceanBlockAdded(inst)
end


