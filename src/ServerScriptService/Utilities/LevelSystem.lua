local SoundFX = game:GetService("ServerStorage"):WaitForChild("Sounds"):WaitForChild("Level Up")
local LevelSystem = {}
 LevelSystem.PlayerXPList = {}

LevelSystem.SetLevelEntry = function(Player,XP)
    -- next level XP required
    LevelSystem.PlayerXPList[Player.UserId] = {["nextLevel"] = 100,
    -- cumalative XP for reduced update processing use
    ["totalXP"] = 0,
    -- cumalative level for reduced update processing use
    ["Level"] = 0}

    local nextLevel = LevelSystem.PlayerXPList[Player.UserId]["nextLevel"]
    local TotalXP = LevelSystem.PlayerXPList[Player.UserId]["totalXP"]
    local loopLevel =  LevelSystem.PlayerXPList[Player.UserId]["Level"]
    local XPCounter = XP
    --Determines the XP required for each interation 
    while(XPCounter >= nextLevel) do
        TotalXP = TotalXP + nextLevel
        if loopLevel < 9 then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.2)
            loopLevel = loopLevel + 1
        elseif(loopLevel < 19) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.1)
            loopLevel = loopLevel + 1
        elseif(loopLevel < 29) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.05)
            loopLevel = loopLevel + 1
        elseif(loopLevel < 39) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.02)
            loopLevel = loopLevel + 1
        elseif(loopLevel < 49) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.011)
            loopLevel = loopLevel + 1
        else
            nextLevel = 3000
            XPCounter = XPCounter - nextLevel
            
            loopLevel = loopLevel + 1
        end 
        if ((XPCounter - nextLevel) < 0) then
            break
        end
        
    end
    LevelSystem.PlayerXPList[Player.UserId]["nextLevel"] = nextLevel
    LevelSystem.PlayerXPList[Player.UserId]["totalXP"] = TotalXP
    LevelSystem.PlayerXPList[Player.UserId]["Level"] = loopLevel

    return loopLevel
end

LevelSystem.SetLevelUpdate = function(Player, XP)
    
    local nextLevel = LevelSystem.PlayerXPList[Player.UserId]["nextLevel"]    
    local loopLevel = LevelSystem.PlayerXPList[Player.UserId]["Level"]
    XPCounter = XP
    XPCounter = XPCounter - LevelSystem.PlayerXPList[Player.UserId]["totalXP"] 
    while(XPCounter >= nextLevel) do
        LevelSystem.PlayerXPList[Player.UserId]["totalXP"] = LevelSystem.PlayerXPList[Player.UserId]["totalXP"] + nextLevel
        if loopLevel <= 10 then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.2)
            loopLevel = loopLevel + 1
        elseif(loopLevel <= 20) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.1)
            loopLevel = loopLevel + 1
        elseif(loopLevel <= 30) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.05)
            loopLevel = loopLevel + 1
        elseif(loopLevel <= 40) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.02)
            loopLevel = loopLevel + 1
        elseif(loopLevel <= 50) then
            XPCounter = XPCounter - nextLevel
            nextLevel = math.floor(nextLevel*1.011)
            loopLevel = loopLevel + 1
        else
            nextLevel = 3000
            XPCounter = XPCounter - nextLevel
            if XPCounter < 0 then
                break
            end
            loopLevel = loopLevel + 1
        end 
        LevelSystem.PlayerXPList[Player.UserId]["nextLevel"] = nextLevel
        LevelSystem.PlayerXPList[Player.UserId]["totalXP"] = LevelSystem.PlayerXPList[Player.UserId]["totalXP"] +nextLevel
        LevelSystem.PlayerXPList[Player.UserId]["Level"] = loopLevel
        LevelSystem.TriggerCelebration(Player)
    end
end

--for leaderboard display
LevelSystem.DisplayLevel = function(Player)
    return  LevelSystem.PlayerXPList[Player.UserId]["Level"]
end
--returns a value between 0-1 for bar tracking
LevelSystem.DisplayProgression = function(Player,XP)
    return ((XP - LevelSystem.PlayerXPList[Player.UserId]["totalXP"]) / LevelSystem.PlayerXPList[Player.UserId]["nextLevel"])
end

LevelSystem.Reset = function(Player)
    LevelSystem.PlayerXPList[Player.UserId]["nextLevel"] = 100
    LevelSystem.PlayerXPList[Player.UserId]["totalXP"] = 0
    LevelSystem.PlayerXPList[Player.UserId]["Level"] = 0
end

-- Both Level system Rewards and the VFX can occur from this function
LevelSystem.TriggerCelebration = function(Player)
    print(Player.Name .. " has leveled up")
    local OneUP = SoundFX:Clone()
    OneUP.Parent = Player.Character:WaitForChild("Head")
    OneUP:Play()
    OneUP:Destroy()

    delay(0,function()local Particles = Instance.new("ParticleEmitter")
        Particles.Parent = Player.Character:WaitForChild("Head")
        Particles.Color =ColorSequence.new(Color3.fromRGB(201, 168, 22))
        Particles.Size = NumberSequence.new(1, 1)
        Particles.Lifetime = NumberRange.new(1, 4)
        Particles.Rate = 100
        Particles.Speed = NumberRange.new(3, 3)
        Particles.SpreadAngle = Vector2.new(1000, 1000)
        task.wait(3)
        Particles.Rate = 0
        task.wait(3)
        Particles:Destroy()
    end)
    --[[
        activate some VFX here on server
    ]]
end
return LevelSystem