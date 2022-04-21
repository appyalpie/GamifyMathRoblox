local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BadgeInformation = require(ReplicatedStorage:WaitForChild("BadgeInformation"))

local UpdateBadgesRE = ReplicatedStorage.RemoteEvents.BadgeEvents:WaitForChild("UpdateBadgesRE")
local UpdateBadgesReadyRE = ReplicatedStorage.RemoteEvents.BadgeEvents:WaitForChild("UpdateBadgesReadyRE")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UniqueOpenGui = PlayerGui:WaitForChild("UniqueOpenGui")
local MenuGui = UniqueOpenGui:WaitForChild("MenuGui")
local InventoryMenu = MenuGui:WaitForChild("InventoryMenu")
local BadgesFrame = InventoryMenu:WaitForChild("BadgesFrame")

local DetailFrame = BadgesFrame:WaitForChild("DetailFrame")
local PictureFrame = DetailFrame:WaitForChild("PictureFrame")
local ImageLabel = PictureFrame:WaitForChild("ImageLabel")
local TextFrame = DetailFrame:WaitForChild("TextFrame")
local Description2 = TextFrame:WaitForChild("Description2") -- Requirements
local Description4 = TextFrame:WaitForChild("Description4") -- Rewards
local Description5 = TextFrame:WaitForChild("Description5") -- Acquired

local AcquiredTextLookup = {
    Acquired = {"<u><b>Acquired</b></u>", Color3.fromRGB(0, 170, 0)},
    NotAcquired = {"<u><b>Not Acquired</b></u>", Color3.fromRGB(170, 0, 0)}
}

local ScrollingFrame = BadgesFrame:WaitForChild("ScrollingFrame")
local Row1 = ScrollingFrame:WaitForChild("1")
local Row2 = ScrollingFrame:WaitForChild("2")

------ Initialize player's badge buttons (assume all are inactive) ------
local function initializeBadgeButtons()
    for _, v in pairs(BadgeInformation) do
        local button = ScrollingFrame:WaitForChild(v.row):WaitForChild(v.column)
        button.InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local badgeKey = button:GetAttribute("badge_key")
                if button:GetAttribute("isActive") == true then
                    ImageLabel.Image = BadgeInformation[badgeKey].imageAssetId
                else
                    ImageLabel.Image = BadgeInformation[badgeKey].darkImageAssetId
                end

                Description2.Text = BadgeInformation[badgeKey].requirements
                Description4.Text = BadgeInformation[badgeKey].rewards
                if button:GetAttribute("isActive") == true then
                    Description5.Text = AcquiredTextLookup.Acquired[1]
                    Description5.TextColor3 = AcquiredTextLookup.Acquired[2]
                else
                    Description5.Text = AcquiredTextLookup.NotAcquired[1]
                    Description5.TextColor3 = AcquiredTextLookup.NotAcquired[2]
                end
            end
        end)
        button.Image = v.darkImageAssetId
        button.HoverImage = v.darkImageAssetId
    end
end

initializeBadgeButtons()

local function findBadgeButton(badgeKey)
    for _, v in pairs(Row1:GetChildren()) do
        if v:GetAttribute("badge_key") == badgeKey then
            return v
        end
    end
    for _, v in pairs(Row2:GetChildren()) do
        if v:GetAttribute("badge_key") == badgeKey then
            return v
        end
    end
end

------ Using a player's badgeTable, set icons grey ------
UpdateBadgesRE.OnClientEvent:Connect(function(badgeTable)
    for _, v in pairs(badgeTable) do
        -- find the badgeButton
        local badgeButton = findBadgeButton(v)
        badgeButton:SetAttribute("isActive", true)
        -- Set badge now not grey
        badgeButton.Image = BadgeInformation[v].imageAssetId
        badgeButton.HoverImage = BadgeInformation[v].imageAssetId
    end
    -- Reset DetailFrame
    ImageLabel.Image = ""
    Description2.Text = ""
    Description4.Text = ""
    Description5.Text = ""
end)

UpdateBadgesReadyRE:FireServer(LocalPlayer)