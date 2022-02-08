--[[
    any Portal Model within a folder will get tagged portal
    in order for teleport to work a new part is to be added to the portal model simply named "Exit" 
    the script will then handle the rest
]]


local collectionService = game:GetService("CollectionService")
local portals = game.workspace:GetChildren()


local PortalActivation = require(script.PortalActivation)

local PortalTraits = {}
PortalTraits.__index = portals
PortalTraits.TAG_NAME = "Portal"


-- adds tag to all portal models found in game as long as each folder location only contains 1 portal
-- only checks from first 
for _,v in ipairs(portals) do
    local portal = v:FindFirstChild("Portal")
    if portal then
        collectionService:AddTag(portal,"Portal")
    end
end

function portals.new(portal)
    local self = {}
    setmetatable(self,PortalTraits)
    self.portal = portal
    print(self.Name)
    self.touchConn = portal.TeleporterINX.Touched:Connect(function(part)
        self:onTouch(part)
    end)
    return self
end
-- an oppurtunity for additonal modularity was added in mind
function portals:onTouch(part)
    local human = part.Parent:FindFirstChild("Humanoid")
    if not human then 
        return 
    end
    -- open gui here
    -- GUI should collect Portal Tag or something to populate the GUI
    --local selection = workspace:WaitForChild("Selection") -- what selects the portal is added here
    PortalActivation.SelectPortal(self.portal , human.Parent:FindFirstChild("HumanoidRootPart"))

    
end


--fires portalActivation event when teleports player to the exit point

--cleanup of portals
-- in the event that dynamic portals are created this code would be used
--[[
    function portals:Cleanup()
        self.touchConn:Disconnect()
        self.touchConn = nil
    end
]]
local PortalArray = {}
local function onPortalAdd(portal)
    if portal:IsA("Model") then
        PortalArray[portal] = portals.new(portal)
    end
end

for _,instance in pairs(collectionService:GetTagged("Portal")) do
    onPortalAdd(instance)
end




