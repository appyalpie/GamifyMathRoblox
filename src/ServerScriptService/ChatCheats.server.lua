local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Noclip = ServerStorage:WaitForChild("Noclip")

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if message == "doukutsumonogatari" then
            local NoclipClone = Noclip:Clone()
            NoclipClone.Parent = player.Backpack
        end
    end)
end)