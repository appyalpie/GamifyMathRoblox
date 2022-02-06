local ZoneLightingHandler = {}

local tweenService = game:GetService("TweenService")
local default = script.parent.parent.Default

function ZoneLightingHandler.Update(zone,transitionOverride)
    for _,v in pairs(default:GetChildren()) do
        if not zone:FindFirstChild(v.Name) then
            v:Clone().parent = zone
        end
    end

    local tweenInfo = TweenInfo.new(transitionOverride or zone.TRANSITION.Value)

    for _,value in pairs(zone:GetChildren()) do
        local modProperties  ={}

        local succ,err = pcall(function()
            if value.Name ~= "TRANSITION" then
                local goal = {[value.Name] = value.Value}
                local tween = tweenService:Create(game.Lighting, tweenInfo, goal)
                tween:Play()
        
                table.insert(modProperties,value.Name)
            end
        end)

        if not succ then
            warn(err)
        end
    end
end

function ZoneLightingHandler.ApplyDefault()
    ZoneLightingHandler.Update(default,0)
end

return ZoneLightingHandler