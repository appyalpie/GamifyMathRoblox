-- Gets music button from the players local UI. 
-- note: WaitForChild MUST be used to find UI elements from PlayerGui due to load times
local muteMusicButton = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PersistentUI"):FindFirstChild("MuteMusic",1)
local InventoryButton = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PersistentUI"):FindFirstChild("Inventory",1)
--Added Code From InventoryGUI 2.0
local MenuGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("UniqueOpenGui"):WaitForChild("MenuGui")
local InventoryGUI = MenuGui:WaitForChild("InventoryScreen")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))

--if more Buttons for menus are used in Persistant GUI a similar form should be used
local OtherGUIinv = {MenuGui:WaitForChild("OptionsMenu");MenuGui:WaitForChild("ShopContainer");MenuGui:WaitForChild("InventoryScreen")}

muteMusicButton.Activated:Connect(function()
    -- Fetch the SoundGroup that music is stored under
    local soundGroupToMute = workspace.Sounds:FindFirstChild("MusicSoundGroup")
    -- Check if volume is NOT 0. If it is NOT 0, mute the SoundGroup, otherwise if it IS 0, set the SoundGroup Volume multiplier to 1
    if soundGroupToMute.Volume ~= 0 
    then
        soundGroupToMute.Volume = 0
    else
        soundGroupToMute.Volume = 1
    end

end)

InventoryButton.Activated:Connect(function()
    GuiUtilities.TweenOtherActiveFramesOut(OtherGUIinv)
    GuiUtilities.TweenInCurrentFrame(InventoryGUI)
end)