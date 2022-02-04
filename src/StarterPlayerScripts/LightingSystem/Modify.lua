
local modify = {}

local TweenService = game:GetService("TweenService")
local default = script.Parent.Parent.DefaultProperties

function modify.Update(trigger, transitionOverride)

    for _,v in pairs(default:GetChildern()) do
        if not trigger:FindFirstChild(v.Name) then
            v:Clone().Parent = trigger
        end
    end
    local tweenInfo = TweenInfo.new(transitionOverride or trigger.TRANSITION.Value)
    for _,value in pairs(trigger:GetChildren()) do
        local modifiedProperties = {}

        local succ,err = pcall(function()
            if value.Name ~= "TRANSITION" then
                local goal = {[value.Name] = value.Value}
                local tween = TweenService:Create(game.Lighting, tweenInfo, goal)
                tween:Play()

                table.insert(modifiedProperties, value.Name)
            end
        end)
        if not succ then
        warn(err)
        end
    end
end

function modify.ApplyDefaults()
    modify.Update(default,0)
end

return modify