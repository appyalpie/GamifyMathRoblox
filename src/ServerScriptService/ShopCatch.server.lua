local GameStats = require(script.Parent.GameStatsInitialization.GameStatsUtilities)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCurrencyEvent =  ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents"):WaitForChild("GetCurrencyEvent")
local SpendCurrencyEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents"):WaitForChild("SpendCurrencyEvent")


local function SendCurrency(player)
    local PlayerCurrency = GameStats.getPlayerData(player)["Currency"]
    GetCurrencyEvent:FireClient(player,PlayerCurrency)
end
local function SpendCurrency(player,Cost)
    local PlayerCurrency = GameStats.getPlayerData(player)["Currency"]
    PlayerCurrency = PlayerCurrency - Cost
end



GetCurrencyEvent.OnServerEvent:Connect(SendCurrency)
SpendCurrencyEvent.OnServerEvent:Connect(SpendCurrency) 