
local collectionService = game:GetService("CollectionService")
--local replicatedStorage = game:GetService("ReplicatedStorage")
-- is meant to find all children within the LightingZones folder in workspace
local Zones = game.Workspace.LightingZones:GetChildern()
-- tags for code
local LightZoneTraits = {}
LightZoneTraits.__index = Zones
LightZoneTraits.TAG_NAME = "LightZone" 

for v=1 , #Zones do
    collectionService:AddTag(Zones[v],LightZoneTraits.TAG_NAME)
end

--if not (game.replicatedStorage:FindFirstChild ("LightEvent")) then
--  Instance.new("RemoteEvent",game.ReplicatedStorage).Name = "LightEvent"
--end

--local LightEvent = game.ReplicatedStorage:FindFirstChild("LightEvent")


--LightZone constructor
function LightZone.new(Zone)
    local self = {}
    setmetatable(self,LightZoneTraits)
    self.LightZone = Zone
    
        self.touchConn = Zone.Touched:Connect(function(...)
        self:onTouch(...)
        end)
    return self
end

-- is meant to change the lighting for the player once the player root has touched the part
-- zone settings are meant to be determined in part settings with a value
function LightZone.onTouch(part)
    local self = {}
    local human = part.parent:GetFirstChild("HumanoidRootPart")

    if not human then
        return
    end
    local lighting = game.Lighting
    lighting.ColorShift_Bottom = self.ColorShift_Bottom.value
    lighting.ColorShift_Top = self.ColorShift_Top.value
    lighting.ClockTime = self.ClockTime.value
    lighting.FogColor = self.FogColor.value
    lighting.FogEnd = self.FogEnd.value
    lighting.Ambient = self.Ambient.value
end

function LightZone:Cleanup()
    self.touchConn:Disconnect()
    self.touchConn = nil
end


--Tag table populator
local function onLightZoneAdded(Zone)
    if Zone:IsA("Part") then
        LightZone[Zone] = LightZone.new(Zone)
    end
end
-- use this to get tagged blocks look above on how to add tags to untagged blocks
for _,inst in pairs(collectionService:GetTagged(LightZone.TAG_NAME)) do
    onLightZoneAdded(inst)
end

--remenants of a diffrent attempt involving a similar process
-- default settings can be modified later
--[[
local default = game.Workspace.Lighting
default.ColorShift_Bottom = Color3.fromRGB(0,0,0)
default.ColorShift_Top = Color3.fromRGB(0,0,0)
default.OutdoorAmbient = Color3.fromRGB(0,0,0)
default.Ambient = Color3.fromRGB(0,0,0)
default.FogStart = 10
default.ClockTime = 0
default.Brightness = 10
default.FogColor = Color3.fromRGB(0,0,0)
default.FogEnd = 20


modify.ApplyDefaults()
    Player.CharacterAdded:Connect(function (character)

        modify.ApplyDefaults()

        local root = character:WaitForChild("HumanoidRootPart")

        root.Touched:Connect (function(trigger)
            if trigger.Parent == triggers then
                modify.Update(trigger)
            end
        end)
    end)
end
]]
