local PotionHitboxFunctions = {}
local debris = game:GetService("Debris")
overlapParams = OverlapParams.new() 

-- prunes the touched list 
PotionHitboxFunctions.StatusPruner = function(Touching, StatusType, StatusName,Position, scaling)
    local prunedList = {}
--enviroment only
if not StatusType then

for _, value in pairs(Touching) do
    if value:isA("Part") and not value.Parent:FindFirstChild("HumanoidRootPart") then
        table.insert(prunedList,value)
    end
end

--all moveable parts
elseif StatusType == 1 then

    for _, value in pairs(Touching) do
        if value:isA("Part") and value.Anchored == false then
            if value.Parent:FindFirstChild("HumanoidRootPart") and not table.find(prunedList, value.Parent) then
                table.insert(prunedList,value.Parent:FindFirstChild("HumanoidRootPart"))
            elseif not value.Parent:FindFirstChild("HumanoidRootPart") then
                table.insert(prunedList,value)
            end
        end
    end


-- player only
elseif StatusType == 2 then 
    for _, value in pairs(Touching) do
        if value.Parent:FindFirstChild("HumanoidRootPart") then
            if not table.find(prunedList, value.Parent:FindFirstChild("HumanoidRootPart")) then
                table.insert(prunedList,value.Parent:FindFirstChild("HumanoidRootPart"))
            end
        end
    end

end

PotionHitboxFunctions.StatusApplier(prunedList, StatusName, Position, scaling)

end
-- applies the potion effects here effects are 
-- Position is specifically for force type potions
-- StatusName is used to determine the effects 
PotionHitboxFunctions.StatusApplier =function(Touched, StatusName, Position, scaling)
    
if StatusName == "Force" then
    
    for _,value in pairs(Touched) do
        coroutine.resume(coroutine.create(function()
            print(value)
        local BodyForce = Instance.new("BodyVelocity")
        BodyForce.Name = "PushForce"
        BodyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local direction = Position - value.Position
        BodyForce.Velocity = ((direction.unit) * -40) *scaling
        BodyForce.Parent = value
        task.wait(0.5)
        BodyForce:Destroy()
        end))
    end
elseif StatusName == "SizeFactor" then
    
    for _,value in pairs(Touched) do
        if value.Name == "HumanoidRootPart" then
            value = value.parent.Humanoid
        end
        coroutine.resume(coroutine.create(function()
        local savedHeadScale = value.HeadScale.Value
        local savedBScale = value.BodyDepthScale.Value
        local savedWScale = value.BodyWidthScale.Value
        local savedHScale = value.BodyHeightScale.Value
        if savedHeadScale >= 7 or savedHeadScale <= 0.24 then
            value.Health = 0
            return
        end
        value.HeadScale.Value = value.HeadScale.Value * scaling 
        value.BodyDepthScale.Value = value.BodyDepthScale.Value * scaling
        value.BodyWidthScale.Value = value.BodyWidthScale.Value * scaling
        value.BodyHeightScale.Value = value.BodyHeightScale.Value * scaling
        task.wait(30*scaling)
        value.HeadScale.Value = savedHeadScale
        value.BodyDepthScale.Value = savedBScale
        value.BodyWidthScale.Value = savedWScale
        value.BodyHeightScale.Value = savedHScale
        if savedHeadScale ~= 1 then
            value.HeadScale.Value = 1
            value.BodyDepthScale.Value = 1
            value.BodyWidthScale.Value = 1
            value.BodyHeightScale.Value = 1
        end
        end))
    end

elseif StatusName == "illusion" then
    
    local PartiticleEmitter = Instance.new("ParticleEmitter")
    PartiticleEmitter.Color = ColorSequence.new(Color3.fromRGB(.4*scaling, .7*scaling, .2*scaling))
    PartiticleEmitter.Lifetime = NumberRange.new(2,5)
    PartiticleEmitter.Rate = 10*scaling
    PartiticleEmitter.Speed = NumberRange.new(20,20)
    PartiticleEmitter.SpreadAngle = Vector2.new(1000,1000)
    PartiticleEmitter.Parent = workspace
    task.wait(5)
    PartiticleEmitter.Rate = 0
    task.wait(5)
    PartiticleEmitter:Destroy()
    

elseif StatusName == "Speed" then
    for _,value in pairs(Touched) do
        if value.Name == "HumanoidRootPart" then
            value = value.parent.Humanoid
        end
        coroutine.resume(coroutine.create(function()
            local saved = value.WalkSpeed
            value.WalkSpeed = value.WalkSpeed * scaling
				-- visual effect gets added here
				local SpeedTrail = Instance.new("Trail")
				SpeedTrail.Color = Color3.fromRGB(255, 243, 73)
				SpeedTrail.Parent = value.Parent.Head
				SpeedTrail.Attachment0 = Instance.new("Attachment",value.Parent.Head)
				SpeedTrail.Attachment1 = Instance.new("Attachment",value.Parent.HumanoidRootPart)

            ----------------------------------
            task.wait(20)
            value.WalkSpeed = saved
            if saved ~= 1 then
                value.WalkSpeed = 1
            end
            -- remove visual effect here
			SpeedTrail:Destroy()
            ----------------------------------
        end))
    end

elseif StatusName == "Jump" then
    for _,value in pairs(Touched) do
        if value.Name == "HumanoidRootPart" then
            value = value.parent.Humanoid
        end
        coroutine.resume(coroutine.create(function()
            local savedJP = value.JumpPower
            local savedJH = value.JumpHeight
               value.JumpPower = value.JumpPower*scaling
               value.JumpHeight = value.JumpHeight * scaling
            -- visual effect gets added here

            ----------------------------------
            task.wait(20)
            value.JumpPower = savedJP
            value.JumpHeight = savedJH
            if savedJP ~= 1 then
                value.JumpPower = 1
                value.JumpHeight = 7.2
            end
            -- remove visual effect here

            ----------------------------------
        end))
    end
end

end

PotionHitboxFunctions.HitboxCreate = function(radius, statusType, Position, StatusName, scaling)
    if not scaling then
        scaling = 1
    end
    print(radius .." ".. statusType .." ".. StatusName .." ".. scaling)
    local Splashbox = Instance.new("Part")
    Splashbox.Parent = workspace
    Splashbox.Shape = "Ball"
    Splashbox.Size = Vector3.new(radius, radius, radius)
    Splashbox.Transparency = 1
    Splashbox.CanCollide = false
    Splashbox.Anchored = true
    Splashbox.Position = Position

    local Touching = workspace:GetPartsInPart(Splashbox,overlapParams)
    Splashbox:Destroy()
    PotionHitboxFunctions.StatusPruner(Touching, statusType, StatusName, Position, scaling)

end



return PotionHitboxFunctions