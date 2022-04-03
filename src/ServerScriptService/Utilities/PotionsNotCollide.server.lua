local CollectionService = game:GetService("CollectionService")
local lightingZones = game.Workspace.LightingZones:GetChildren()
local MusicZones = game.Workspace.Sounds.MusicZones:GetDescendants()
local Locations= game.Workspace.Locations:GetChildren()
local PotionProjectile = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ThrowPotion")
local Main_hubEffects = game.Workspace.Main_Hub_Enclave.Floor.Effects:GetDescendants()

local Filter = {}
Filter._index = {lightingZones,MusicZones, Locations,Main_hubEffects}
Filter.TAG_NAME = "NoCollidePotions"


-- add tag to all Filter parts
for i,_ in pairs(Filter._index) do
	for _,v in pairs(Filter._index[i]) do
		local zone = v:IsA("Part")
		if zone then
				
				CollectionService:AddTag(v,Filter.TAG_NAME)
		end
    end
end
--whenever a projectile is created all tagged parts excute this
function NoCollision(part,zone)
    local NoConstraint = Instance.new("NoCollisionConstraint")
    NoConstraint.Part0 = zone
    NoConstraint.Part1 = part
    NoConstraint.Parent = part
end
-- adds the previous function to all tagged parts
function Filter.new(zone)
    local self = {}
    setmetatable(self,Filter)
    self.zone = zone
    PotionProjectile.OnServerEvent:Connect(function(player,part)
        NoCollision(part,zone)
    end)
    
end
--Fires the Filter.new() 
for _,instance in pairs(CollectionService:GetTagged(Filter.TAG_NAME)) do
    Filter.new(instance)
end