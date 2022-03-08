local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnlockBarrierRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("UnlockBarrierRE")
local Barrier = game.Workspace.Island_2.Barrier

UnlockBarrierRE.OnClientEvent:Connect(function()
    print("FIRED")
    Barrier.Barrier_Part:Destroy()
    Barrier.BeamHolder.Attachment0.Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 194, 23)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 194, 23))
    }
end)