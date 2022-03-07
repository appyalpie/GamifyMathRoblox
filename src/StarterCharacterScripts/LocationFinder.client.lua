--[[show a text box with the location according to a player colliding with 
a "zone" object. text box should tween into position and then go away after 5 seconds. need to handle
debounce as well. if possible, make the location GUI pop-up once per game round.]]

--bring in services and local variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--local LocationModule = require(ReplicatedStorage.LocationModule)-- not using module yet
local Player = game:GetService("Players").LocalPlayer
--local Locations = game.Workspace.Locations
local LocationEvent = ReplicatedStorage:WaitForChild('LocationEvent')

local LocationGUI = Player:WaitForChild("PlayerGui"):WaitForChild("LocationGUI")
local LocationFrame = LocationGUI:WaitForChild("LocationFrame")
--local LocationFrame = Player:WaitForChild("PlayerGui"):WaitForChild("LocationGUI"):WaitForChild("LocationFrame")


--triggers and counts
--local LocationOpen = false
local LocationTween = nil
--local LocationIndex = 0
--local GradualTextInProgress = false
--local TEXT_SPEED = .01
local DURATION = 5
local LastLocation

--functions
--function to display text gradually. might not want gradual text yet
--[[
local function GradualText(Text)
    if GradualTextInProgress then
        return
    end

    local Length = string.len(Text)

    for i = 1, Length, 1 do
        GradualTextInProgress = true
        LocationFrame.LocationText.Text = string.sub(Text, 1, i)
        wait(TEXT_SPEED)
    end

    GradualTextInProgress = false
end
]]

--handles the event, play a function that will make a GUI appear and disappear after 5 seconds
LocationEvent.OnClientEvent:Connect(function(LocationName)
    local Location = LocationName 

    --enable GUI--maybe throw in an if check
    LocationGUI.Enabled = true

    if Location ~= LastLocation then

        --make Gui appear. tween the gui into view
        --this tweens the frame into view
        if LocationTween then
            LocationTween:Cancel()
            LocationTween = nil
        end
        --connect tween to handle LocationFrame at correct screen position    
        local Tween = TweenService:Create(LocationFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.2, 0, 0.03, 0)
        })
        LocationTween = Tween
        LocationTween:Play()

        
        --fill the location frame text box with the correct location passed from remote event  
        --GradualText(Location)
        LocationFrame.LocationText.Text = Location

        --wait the duration amount then tween the window back to it's spot. 
        wait(DURATION)
        Tween = TweenService:Create(LocationFrame, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 2, 0)
        })
        LocationTween = Tween
        LocationTween:Play()

        --set the current location passed into lastlocation for the check up top
        LastLocation = Location
    end
end)
