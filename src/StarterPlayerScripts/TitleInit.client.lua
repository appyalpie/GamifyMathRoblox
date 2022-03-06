local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local getTitles = ReplicatedStorage:WaitForChild("GetTitlesEvent")
local addTitleRepopulate = ReplicatedStorage:WaitForChild("AddTitlesEvent")
 
local titles = getTitles:InvokeServer(Players.LocalPlayer)

local overheadTitle = Players.LocalPlayer.Character.Head:WaitForChild("overheadTitle")


-- This is just a small remoteevent that gets titles from the server
-- anytime a title is added (see TitleModule.AddTitle)
local function onAddTitleFire(player)
    titles = getTitles:InvokeServer()
    wait(1)
end
 
addTitleRepopulate.OnClientEvent:Connect(onAddTitleFire)

local function DisplayTitle(titleName)
    for key, value in pairs(titles) do
        if value == titleName then
            overheadTitle.TextLabel.Text = titleName
        end
    end
end

DisplayTitle("Serf")

