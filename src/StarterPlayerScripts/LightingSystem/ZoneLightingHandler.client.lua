local Lighting = game:GetService("Lighting")


local Player = game.Players.LocalPlayer
local triggers = game.Workspace.LightingZones
local modify = require(script.Modify.lua)

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
default.TRANSITION = 3
]]

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








