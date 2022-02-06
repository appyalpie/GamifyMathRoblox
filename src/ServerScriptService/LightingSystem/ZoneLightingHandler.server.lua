
local collectionService = game:GetService("CollectionService")
local tweenService = game:GetService("TweenService")
--local replicatedStorage = game:GetService("ReplicatedStorage")
-- is meant to find all children within the LightingZones folder in workspace
local Zones = game.Workspace.LightingZones:GetChildren()
print(Zones)
-- tags for code
local LightZoneTraits = {}
LightZoneTraits.__index = Zones
LightZoneTraits.TAG_NAME = "LightZone" 

for i = 1, #Zones do
    collectionService:AddTag(Zones[i],LightZoneTraits.TAG_NAME)
end

--if not (game.replicatedStorage:FindFirstChild ("LightEvent")) then
--  Instance.new("RemoteEvent",game.ReplicatedStorage).Name = "LightEvent"
--end

--local LightEvent = game.ReplicatedStorage:FindFirstChild("LightEvent")


--LightZone constructor
function Zones.new(LightZone)
    local self = {}
    setmetatable(self,LightZoneTraits)
    self.LightZone = LightZone
    
        self.touchConn = LightZone.Touched:Connect(function(...)
        self:onTouch(...)
        end)
    return self
end

-- is meant to change the lighting for the player once the player root has touched the part
-- zone settings are meant to be determined in part settings with a value
function Zones:onTouch(part)
   
    --self.debounce = false
    local human = part.parent:FindFirstChild("Humanoid")
     if not human then
        return
     end
     local tweenInfo = TweenInfo.new()

     for _, value in pairs(self:GetChildren())do
        local ZoneLightingHandler = {}
        local succ, err = pcall(function ()
            local goal = {[value.Name] = value.Value}
            local tween = tweenService:Create(game.Lighting, tweenInfo, goal)
            tween:Play()
            table.insert(ZoneLightingHandler,value.Name)
        end)
        if not succ then
            warn(err)
        end
    end
end
-- Tag cleanup
function Zones:Cleanup()
    self.touchConn:Disconnect()
    self.touchConn = nil
end

local LightZones = {}
--Tag table populator
local function onLightZoneAdded(Zone)
    if Zone:IsA("Part") then
        LightZones[Zones] = Zones.new(Zone)
    end
end
-- use this to get tagged blocks look above on how to add tags to untagged blocks
for _,inst in pairs(collectionService:GetTagged(LightZoneTraits.TAG_NAME)) do
    onLightZoneAdded(inst)
end

