local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local AddTitlesEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("AddTitlesEvent")
local InitTitlesEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("InitTitlesEvent")
local ShowTitlesEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("ShowTitlesEvent")
local PlayerSideHideNameAndTitleEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild('PlayerSideHideNameAndTitleEvent')
local PlayerSideShowNameAndTitleEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild('PlayerSideShowNameAndTitleEvent')
local ActivateTitleButtonEvent = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("ActivateTitleButtonEvent")

local Player = Players.LocalPlayer
local overheadTitle = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadTitle")
local overheadName = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadName")
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("UniqueOpenGui"):WaitForChild("MenuGui"):WaitForChild("InventoryMenu")
local TitleList = InventoryGUI:WaitForChild("TitlesFrame"):WaitForChild("InlayFrame")

local titles = {}

-- TODO: apply title applied when the player left
local function DisplayTitle(titleName)
    for key, value in pairs(titles) do
        if value == titleName then
            ShowTitlesEvent:FireServer(titleName)
            --overheadTitle.TextLabel.Text = titleName
        end
    end
end

local function HideTitle()
    ShowTitlesEvent:FireServer("")
end

--begin populate gui code
local function addToFrame(title)
    -- Check if the button already exists
    local temp = TitleList:GetChildren()
    for i = 1, #temp do
        if temp[i]:IsA("TextButton") then
            if temp[i].Text == title then
                return
            end
        end
    end
    -- Create a new button, set parent to TitleList and text to the title
    local textButton = ReplicatedStorage:WaitForChild("InventoryScrollingButtonBasic"):Clone()
    textButton.Parent = TitleList
    textButton.Text = title
    if textButton.TextFits == false then
        textButton.TextScaled = true
    end
    -- On activation, set Selected on all other buttons to false and
    -- make other buttons background transparent
    textButton.Activated:Connect(function()
        if textButton.Selected == true then
            HideTitle()
            textButton.Selected = false
            textButton.BackgroundTransparency = 1.0
            return
        end
        DisplayTitle(textButton.text)
        local temp = TitleList:GetChildren()
        for i = 1, #temp do
            if temp[i]:IsA("TextButton") then
                temp[i].Selected = false
                temp[i].BackgroundTransparency = 1.0
            end
        end
        textButton.BackgroundTransparency = 0.7
        textButton.Selected = true
        currentTitle = textButton.text
    end)

    -- When the mouse scrolls over the button, show a yellow background
    textButton.MouseEnter:Connect(function()
        if textButton.Selected == false then
            textButton.BackgroundTransparency = 0.9
        end
    end)

    -- When the mouse leaves the button, make the background transparent again
    textButton.MouseLeave:Connect(function()
        if textButton.Selected == false then
            textButton.BackgroundTransparency = 1.0
        end
    end)
end

local function Populate()
    if titles ~= nil then
        for i,title in pairs(titles) do
            addToFrame(title)
        end
    end
end

-- This is just a small remoteevent that gets titles from the server
-- anytime a title is added (see TitleModule.AddTitle)
local function onAddTitleFire(title)
    table.insert(titles, title)
    Populate()
end
 
AddTitlesEvent.OnClientEvent:Connect(onAddTitleFire)

local function onInitTitlesEvent(serverTitles)
    titles = serverTitles
    Populate()
end

InitTitlesEvent.OnClientEvent:Connect(onInitTitlesEvent)

local function onActivateTitleButton(titleName)
    for _,v in pairs(TitleList:GetChildren()) do
        if v:IsA("TextButton") and v.Text == titleName then
            DisplayTitle(v.Text)
            v.BackgroundTransparency = 0.7
            v.Selected = true
        end
    end
end

ActivateTitleButtonEvent.OnClientEvent:Connect(onActivateTitleButton)

local function onPlayerSideHideNameAndTitle()
    -- Redefine in case player has died b/c a new model is created --
    local overheadTitle = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadTitle")
    local overheadName = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadName")
    overheadName.TextLabel.Visible = false
    overheadTitle.TextLabel.Visible = false
end

PlayerSideHideNameAndTitleEvent.OnClientEvent:Connect(onPlayerSideHideNameAndTitle)

local function onPlayerSideShowNameAndTitle()
    local overheadTitle = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadTitle")
    local overheadName = game.Workspace:WaitForChild(Player.Name):WaitForChild("Head"):WaitForChild("overheadName")
    overheadName.TextLabel.Visible = true
    overheadTitle.TextLabel.Visible = true
end

PlayerSideShowNameAndTitleEvent.OnClientEvent:Connect(onPlayerSideShowNameAndTitle)



