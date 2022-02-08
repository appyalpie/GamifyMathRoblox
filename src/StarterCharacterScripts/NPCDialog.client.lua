--bring in services and local variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local DialogModule = require(ReplicatedStorage.DialogModule)
local Player = game:GetService("Players").LocalPlayer
local NPCs = game.Workspace.Island_1.NPCs

--[[
    or do i use this?
    game.Workspace.Island_1.NPCs:GetChildren()
    these need to be checked. I want the constituent parts of the service.
]]
local DialogFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog"):WaitForChild("DialogFrame")
local InputButton =  DialogFrame:WaitForChild("Input")
--this is the NPC name label in the dialog frame maybe not correct
local NPCName = DialogFrame:WaitForChild("NPCName")


--triggers and counts
local DialogOpen = false
local DialogTween = nil
local DialogIndex = 0
local GradualTextInProgress = false
local TEXT_SPEED = .01

--functions
--helper function
--gradually print text from dialog module
local function GradualText(Text)
    if GradualTextInProgress then
        return
    end

    local Length = string.len(Text)

    for i = 1, Length, 1 do
        GradualTextInProgress = true
        DialogFrame.DialogText.Text = string.sub(Text, 1, i)
        wait(TEXT_SPEED)
    end

    GradualTextInProgress = false
end

--handle dialog given proximity prompt. bring in dialog associated with individual NPC base on dialog module script
local function OnDialog(Dialog, Index, ProximityPrompt)
    --if there is dialog at the index provided (pages of dialog lines)
    if Dialog[Index] then
        --display dialog text at the page spot
        GradualText(Dialog[Index])
    else
        --if the tween exists then cancel
        if DialogTween then
            DialogTween:Cancel()
            DialogTween = nil
        end
        --setup and play tween
        local Tween = TweenService:Create(DialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 2, 0)
        })
        DialogTween = Tween
        DialogTween:Play()

        ProximityPrompt.Enabled = true
        DialogOpen = false
        DialogIndex = 0
        Player.Character.HumanoidRootPart.Anchored = false
    end
end

--in future use context action service space bar. human computer interaction! future feature.
InputButton.MouseButton1Click:Connect(function()
    if GradualTextInProgress then
        return
    end

    local Dialog = DialogModule[NPCName.Value] --check this
    DialogIndex += 1 
    OnDialog(Dialog, DialogIndex, NPCs[NPCName.Value].HumanoidRootPart.ProximityPrompt)
end)

--loop through npcs in NPCs directory
for _, v in pairs(NPCs:GetChildren()) do
    local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
    local ProximityPrompt = HumanoidRootPart:FindFirstChild("ProximityPrompt")

    if HumanoidRootPart and ProximityPrompt then
        ProximityPrompt.ObjectText = v.Name
        ProximityPrompt.ActionText = "Chat with " .. v.Name
        
        local Dialog = DialogModule[v.Name]
        ProximityPrompt.Triggered:Connect(function()
            if DialogOpen then
                return
            end
            
            DialogOpen = true
            ProximityPrompt.Enabled = false
            NPCName.Value = v.Name
            Player.Character.HumanoidRootPart.Anchored = true

            if DialogTween then
                DialogTween:Cancel()
                DialogTween = nil
            end
            --connect tween to handle DialogFrame    
            local Tween = TweenService:Create(DialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.1, 0, 0.73, 0)
            })
            DialogTween = Tween
            DialogTween:Play()

            DialogIndex = 1
            OnDialog(Dialog, DialogIndex, ProximityPrompt)
        end)
    end
end
