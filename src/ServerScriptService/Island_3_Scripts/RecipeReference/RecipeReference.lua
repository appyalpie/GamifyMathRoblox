local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

local PlayerSideHideNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideHideNameAndTitleEvent")
local PlayerSideShowNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideShowNameAndTitleEvent")

RecipeReference = {}

RecipeReference.MoveCamera = function(player, table)
    local newCamera = table.Paper.SurfaceGuiPart.PaperCameraLocation
    CameraMoveToRE:FireClient(player, newCamera, 1)
    PlayerSideHideNameAndTitleRE:FireClient(player)

    wait(5)

    CameraResetRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)

end

return RecipeReference