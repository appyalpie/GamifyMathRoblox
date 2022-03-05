local ServerStorage = game:GetService("ServerStorage")
local Overhead = ServerStorage.Titles:WaitForChild("overhead")

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
    
        local overheadClone = Overhead:Clone()
        -- we wait for the clone to finish I think?
        wait(1)
        overheadClone.Parent = character.Head
        overheadClone.TextLabel.Text = ("Grandmaster " .. player.name)

        character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    end)
end)