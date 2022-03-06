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
    print(titles)
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

--begin populate gui code
local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventroyGUI"):WaitForChild("InventoryScreen")
local TitleList = InventoryGUI:WaitForChild("TFrame")

local function addToFrame(title)
    local textButton = ReplicatedStorage:WaitForChild("InventoryScrollingButtonBasic"):Clone()
    textButton.Parent = TitleList
    textButton.Text = title
    if textButton.TextFits == false then
        textButton.TextScaled = true
    end
    textButton.Activated:Connect(function()
        DisplayTitle(textButton.text)
        local temp = TitleList:GetChildren()
        for i = 1, #temp do
            if temp[i]:IsA("TextButton") then
                temp[i]:SetAttribute("chosen", false)
                temp[i].BackgroundTransparency = 1.0
            end
        end
        textButton.BackgroundTransparency = 0.7
        textButton:SetAttribute("chosen", true)
    end)

    textButton.MouseEnter:Connect(function()
        if(textButton:GetAttribute("chosen") == false) then
            textButton.BackgroundTransparency = 0.9
        end
    end)

    textButton.MouseLeave:Connect(function()
        if(textButton:GetAttribute("chosen") == false) then
            textButton.BackgroundTransparency = 1.0
        end
    end)
end


local function Populate()
    for i,title in pairs(titles) do
        addToFrame(title)
    end
end

Populate()


