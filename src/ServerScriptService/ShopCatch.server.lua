local GameStats = require(script.Parent.GameStatsInitialization.GameStatsUtilities)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCurrencyEvent =  ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents"):WaitForChild("GetCurrencyEvent")
local SpendCurrencyEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents"):WaitForChild("SpendCurrencyEvent")
local OpenShopEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents"):WaitForChild("OpenShopEvent")

local function SendCurrency(player)
    local PlayerCurrency = GameStats.getPlayerData(player)["Currency"]
    GetCurrencyEvent:FireClient(player,PlayerCurrency)
end
local function SpendCurrency(player,Cost)
    local PlayerCurrency = GameStats.getPlayerData(player)["Currency"]
    PlayerCurrency = PlayerCurrency - Cost
    GameStats.getPlayerData(player)["Currency"] = PlayerCurrency
end

local function OpenShop(player)
    OpenShopEvent:FireClient(player)
end 


GetCurrencyEvent.OnServerEvent:Connect(SendCurrency)
SpendCurrencyEvent.OnServerEvent:Connect(SpendCurrency) 
OpenShopEvent.OnServerEvent:Connect(OpenShop)

