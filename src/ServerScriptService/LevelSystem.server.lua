local Players = game:GetService("Players")
local LevelSystem = require(script.Parent.Utilities.LevelSystem)
local GameStats = require(script.Parent.GameStatsInitialization.GameStatsUtilities)
-- TODO Display Level on server in leadboard style


Players.PlayerAdded:Connect(function(player)
    local PlayerStats = GameStats.getPlayerData(player)
    local XP = PlayerStats["XP"]
    LevelSystem.SetLevelEntry(player,XP)

    LevelSystem.SetLevelUpdate(player,(XP))

    PlayerStats["XP"].Changed:Connect(LevelSystem.SetLevelUpdate(player,XP))

end)
