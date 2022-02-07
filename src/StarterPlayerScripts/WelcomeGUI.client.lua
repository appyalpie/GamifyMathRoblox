
--get local player and gui parts and blur
local startButton = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("StartScreen"):FindFirstChild("StartButton")
--local startScreen = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):FindFirstChildWhichIsA("StartScreen")
local blur = game:GetService("Lighting").Blur

--ensure these things load in before script starts


--turn the blur on upon spawn
blur.Enabled = true

--handle someone clicking on the button 
startButton.Activated:Connect(function()
    --local startScreen = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):FindFirstChildWhichIsA("TextButton")
    startButton.Parent:Destroy()--destroys the screen gui
    blur.Enabled = false
end)  
--end



