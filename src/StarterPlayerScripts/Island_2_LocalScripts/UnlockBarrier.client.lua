local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnlockBarrierRE = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild("UnlockBarrierRE")
local UnlockIsland3BarrierRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("UnlockIsland3BarrierRE")
local PortalGuiUpdateIsland3BE = ReplicatedStorage.RemoteEvents:WaitForChild("PortalGuiUpdateIsland3BE")
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

UnlockIsland3BarrierRE.OnClientEvent:Connect(function()
    print("FIRED ISLAND 3 UNLOCK")
    PortalGuiUpdateIsland3BE:Fire(true)
    local Barrier = game.Workspace.Island_3.Barrier
    if Barrier:FindFirstChild("Barrier_Part") then
        Barrier.Barrier_Part:Destroy()
        Barrier.BeamHolder.Attachment0.Beam.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 194, 23)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 194, 23))
            }
    end
end)