local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")

local PlayerSideHideNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideHideNameAndTitleEvent")
local PlayerSideShowNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideShowNameAndTitleEvent")

local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

local tablePosition = game.Workspace.Island_3.test_zone.Table.Position

local TABLE_OFFSET = Vector3.new(3.5, 1.5, -3.5)

PotionCreation = {}

function PotionCreation.initialize(player)
    player.Character:WaitForChild("HumanoidRootPart").Position = tablePosition + TABLE_OFFSET
    --CameraMoveToRE:FireClient(player, 2, 2, 2)
    LockMovementRE:FireClient(player)
    PlayerSideHideNameAndTitleRE:FireClient(player)
    wait(5)
    UnlockMovementRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)
end

return PotionCreation