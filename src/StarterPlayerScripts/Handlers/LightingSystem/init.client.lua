
local collectionService = game:GetService("CollectionService")
-- is meant to find all children within the LightingZones folder in workspace
local Zones = game.Workspace.LightingZones:GetChildren()

local player = game.Players.LocalPlayer
local zones = game.Workspace.LightingZones
local default = script.parent.Default
local ZoneLightingHandler = require(script.ZoneLightingHandler)

ZoneLightingHandler.ApplyDefault()

player.CharacterAdded:Connect(function(character)
    ZoneLightingHandler.ApplyDefault()
    
    local root = character:WaitForChild("HumanoidRootPart")
    
    root.Touched:Connect(function(zone)
        if zone.Parent == zones then
            ZoneLightingHandler.Update(zone)
        end
    end)
end)

-- tag for traits and default values for traits
local LightZoneTraits = {}
LightZoneTraits.__index = Zones
LightZoneTraits.TAG_NAME = "LightZone" 


for i = 1, #Zones do
    collectionService:AddTag(Zones[i],LightZoneTraits.TAG_NAME)
end





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
--[[

    THE CURRENT PROBLEM is i can't figuire out why self returns nil once i can get it where the part 
    properties are reconized code should work. this is purely syntax in what i can observe
    

]]
function Zones:onTouch(part)


   --[[
    self.debounce = false
    local human = part.parent:FindFirstChild("Humanoid")
     if not human then
        return
     end
     if not self.TRANSITION.Value then
        self.TRANSITION.Value = LightZoneTraits.TRANSITION
     end

     local tweenInfo = TweenInfo.new(self.TRANSITION.Value)

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
    --]]
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

