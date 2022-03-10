local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------ Camera Util Initialization ------
local CameraUtil = require(ReplicatedStorage:WaitForChild("CameraUtil"))
local functions = CameraUtil.Functions
local shakePresets = CameraUtil.ShakePresets
local cameraInstance = workspace.CurrentCamera
local camera = CameraUtil.Init(cameraInstance)

----- Remote Events ------
local CameraPointToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraPointToRE")
local CameraFollowRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraFollowRE")
local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

----- Remote Event Binding ------
CameraPointToRE.OnClientEvent:Connect(function(target, duration, style, direction)
    camera:PointTo(target, duration, style, direction)
end)

CameraFollowRE.OnClientEvent:Connect(function(part)
    camera:Follow(part)
end)

CameraMoveToRE.OnClientEvent:Connect(function(target, duration, style, direction)
    camera:MoveTo(target, duration, style, direction)
end)

CameraResetRE.OnClientEvent:Connect(function()
    camera:Reset()
end)

CameraSetFOVRE.OnClientEvent:Connect(function(fov, duration, style, direction)
    camera:SetFOV(fov, duration, style, direction)
end)