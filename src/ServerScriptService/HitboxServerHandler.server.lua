local HitboxFunctions = require(script.Parent.PotionStatusHitbox)

local potionhitboxBE = game:GetService("ReplicatedStorage").RemoteEvents.PotionHitboxBE

potionhitboxBE.Event:Connect(function(radius, statusType, Position, StatusName, scaling)
    HitboxFunctions.HitboxCreate(radius,statusType,Position,StatusName,scaling)
end)
