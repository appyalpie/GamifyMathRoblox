local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local getTitles = ReplicatedStorage:WaitForChild("GetTitlesEvent")
local addTitleRepopulate = ReplicatedStorage:WaitForChild("AddTitlesEvent")
 
--local titles = getTitles:InvokeServer(Players.LocalPlayer)

--print(titles)

local function onAddTitleFire(player)
    local titles2 = getTitles:InvokeServer()

    print(titles2)
end
 
addTitleRepopulate.OnClientEvent:Connect(onAddTitleFire)