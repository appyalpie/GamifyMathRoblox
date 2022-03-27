local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnlockBarrierRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("UnlockBarrierRE")
local Barriers = game.Workspace.Island_2.Barriers:GetChildren()

UnlockBarrierRE.OnClientEvent:Connect(function()
    print("FIRED")
    for _, v in pairs(Barriers) do
        if v:FindFirstChild("Barrier_Part") then
            v.Barrier_Part:Destroy()
            v.BeamHolder.Attachment0.Beam.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 194, 23)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 194, 23))
            }
        end
    end
end)