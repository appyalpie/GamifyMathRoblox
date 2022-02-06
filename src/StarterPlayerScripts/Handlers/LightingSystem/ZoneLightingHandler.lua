local ZoneLightingHandler = {}

local tweenService = game:GetService("TweenService")
local default = script.parent.parent.Default

--Update is the function that calls for switching Lighting properties
--so long as lighting has the property a variable can be added to zones as long as a
-- default exist in the folder

function ZoneLightingHandler.Update(zone,transitionOverride)
    for _,v in pairs(default:GetChildren()) do
        if not zone:FindFirstChild(v.Name) then
            v:Clone().parent = zone
        end
    end

    local tweenInfo = TweenInfo.new(transitionOverride or zone.TRANSITION.Value)

    for _,value in pairs(zone:GetChildren()) do
        local modProperties  ={}

        --pcall is the try and catch within roblox lua
        local Success,Error = pcall(function()
            if value.Name ~= "TRANSITION" then
                local goal = {[value.Name] = value.Value}
                local tween = tweenService:Create(game.Lighting, tweenInfo, goal) -- looked at tween a little here
                tween:Play()
        
                table.insert(modProperties,value.Name)
            end
        end)

        --first version Catch, it is outside the pcall
        if not Success then
            warn(Error)
        end
    end
end

function ZoneLightingHandler.ApplyDefault()
    ZoneLightingHandler.Update(default,0)
end

return ZoneLightingHandler