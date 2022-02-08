local collectionService = game:GetService("CollectionService")
local portals = game.workspace:GetChildren()

local Player = game:GetService('Players').LocalPlayer

Player.CharacterAdded:Wait()

local PortalActivation = require(script.PortalActivation)

local PortalTraits = {}
PortalTraits._INDEX = portals
PortalTraits.TAG_NAME = "Portal"


-- adds tag to all portal models found in game as long as each folder location only contains 1 portal
-- only checks from first 
for _,v in ipairs(portals) do
    local portal = v:FindFirstChild("Portal")
    if portal then
        collectionService:AddTag(portal,"Portal")
    end
end

-- defines what tag do 

function Portal.new(portal)
    local self = {}
    setmetatable(self,PortalTraits)
    self.Portal = portal
    self.touchConn = portal.TeleporterINX.Touched:Connect(function(...)
        self:onTouch(...)
    end)
    return self
end

function Portal:onTouch(part)
    local human = part.Parent:FindFirstChild("Humanoid")
    if not human then 
        return 
    end
    -- open gui here
    -- GUI should collect Portal Tag or something to populate the GUI
    --local selection = workspace:WaitForChild("Selection") -- what selects the portal is added here
    --PortalActivation.SelectPortal(selection,human.Parent:FindFirstChild("HumanoidRootPart"))

    
end


--fires portalActivation event when teleports player to the exit point

--cleanup of tags
function Portal:Cleanup()
    self.touchConn:Disconnect()
    self.touchConn = nil
end
local PortalArray = {}
local function onPortalAdd(portal)
    if portal.IsA("Model") then
        PortalArray[portal] = Portal.new(portal)
    end
end

for _,instance in pairs(collectionService:GetTagged("Portal")) do
    onPortalAdd(instance)
end




