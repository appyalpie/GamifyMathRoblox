local ReplicatedStorage = game:GetService("ReplicatedStorage")
--get local player and gui parts and blur
local StartButton = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("StartScreen"):FindFirstChild("StartButton")
--local startScreen = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):FindFirstChildWhichIsA("StartScreen")
local Blur = game:GetService("Lighting").Blur
local BlurRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BlurRE")
--ensure these things load in before script starts


--turn the blur on upon spawn
--blur.Enabled = true --been moved clean up later

--handle someone clicking on the button 
StartButton.Activated:Connect(function()
    --local startScreen = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):FindFirstChildWhichIsA("TextButton")
    StartButton.Parent:Destroy()--destroys the screen gui
    Blur.Enabled = false
end)  
--end

local function OnBlurREEvent()
    Blur.Enabled = true
end

BlurRE.OnClientEvent:Connect(OnBlurREEvent)



