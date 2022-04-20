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

local ScrollingFrame = BadgesFrame:WaitForChild("ScrollingFrame")
local Row1 = ScrollingFrame:WaitForChild("1")
local Row2 = ScrollingFrame:WaitForChild("2")