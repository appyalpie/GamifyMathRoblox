local ServerStorage = game:GetService("ServerStorage")
local overheadName = ServerStorage.Titles:WaitForChild("overheadName")
local overheadTitle = ServerStorage.Titles:WaitForChild("overheadTitle")
local titleModule = require(game.ServerScriptService:WaitForChild("TitleModule"))

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
    
        local IDs = {0, 1, 3, 4, 6, 20}
        local titleArray = titleModule.parseTitleIDs(IDs)

        local overheadTitleClone = overheadTitle:Clone()
        local overheadNameClone = overheadName:Clone()
        -- we wait for the clone to finish I think?
        wait(1)
        overheadNameClone.Parent = character.Head
        overheadTitleClone.Parent = character.Head
        character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        overheadNameClone.TextLabel.Text = (player.name)

        for i = 1, #titleArray do
            overheadTitleClone.TextLabel.Text = (titleArray[i])
            wait(5)
        end

    end)
end)