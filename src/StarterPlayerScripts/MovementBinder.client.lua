local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local function lockMovement()
    print("Locking")
    Controls:Disable()
end

local function unlockMovement()
    print("Unlocking")
    Controls:Enable(true)
end

LockMovementRE.OnClientEvent:Connect(lockMovement)
UnlockMovementRE.OnClientEvent:Connect(unlockMovement)