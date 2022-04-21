local DataStoreService = game:GetService("DataStoreService")
local playerLevelStore2 = DataStoreService:GetOrderedDataStore("PlayerLevelStore2")
local Players = game:GetService("Players")
local LevelSystem = require(script.Parent.Utilities.LevelSystem)
local GameStats = require(game:GetService("ServerScriptService"):WaitForChild("GameStatsInitialization"):WaitForChild("GameStatsUtilities"))
local UpdateLeaderBoardRE = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents"):WaitForChild("UpdateLeaderBoardRE")

local ConnectedPlayers = {}

--local LeadboardGUI = game.Workspace.
-- TODO Display Level on server in leadboard style


Players.PlayerAdded:Connect(function(player)
    wait(1) -- wait for the datastore to retrieve the value
    local PlayerStats = GameStats.getPlayerData(player)
    print(PlayerStats["XP"])
    local XP = PlayerStats["XP"]
    LevelSystem.SetLevelEntry(player,XP)

    print(LevelSystem.DisplayLevel(player)) -- test code to show Player Level after connecting
    --if PlayerLevelStore:
    playerLevelStore2:setAsync(player.UserId,XP)
    table.insert(ConnectedPlayers,player.UserId)
    -- test code for changing XP value in non-game place enviorment 
    --LevelSystem.SetLevelUpdate(player,(XP+3000))
end)

Players.PlayerRemoving:Connect(function(player)
    local PlayerStats = GameStats.getPlayerData(player)
    print(PlayerStats["XP"])
    local XP = PlayerStats["XP"]
    playerLevelStore2:setAsync(player.UserId,XP)
    table.remove(ConnectedPlayers,table.find(ConnectedPlayers,player))
end)

coroutine.resume(coroutine.create(function()
    while true do 
        task.wait(300) -- trigger a server update every 5 minutes
        local clientTable = {}
        for i in pairs(ConnectedPlayers) do
            print(ConnectedPlayers[i])
             playerLevelStore2:setAsync(ConnectedPlayers[i], (GameStats.getPlayerData(Players:GetPlayerByUserId(ConnectedPlayers[i])))["XP"])
             print(Players:GetPlayerByUserId(ConnectedPlayers[i]))
        end

        local pages = playerLevelStore2:GetSortedAsync(false,10)
        local FirstPage = pages:GetCurrentPage()
        for _,v in pairs(FirstPage) do
            local PlayerItem = {}
            local player = tonumber(v.key)
            local value = LevelSystem.DisplayLevel(Players:GetPlayerByUserId(tonumber(v.key)))
            
            if player and value then
                table.insert(PlayerItem,player,value)
                print(PlayerItem)
                table.insert(clientTable,PlayerItem)
            end
            -- update leaderboard GUI
        end

        print(clientTable)
        -- advance to look or not at all
        UpdateLeaderBoardRE:FireAllClients(clientTable)
        
    end 
end))


