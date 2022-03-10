--bring in services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DialogModule = require(ReplicatedStorage.DialogModule)
local Player = game:GetService("Players").LocalPlayer
--all NPCs should be in island 1 otherwise change this eventually
local NPCs = game.Workspace.Island_1.NPCs
--declare remote events
local ChallengeEvent = ReplicatedStorage.RemoteEvents.Island_2:WaitForChild('ChallengeEvent')
    
--GUI variables
local DialogFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog"):WaitForChild("DialogFrame")
local YesNoFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog"):WaitForChild("YesNoFrame")
local InputButton =  DialogFrame:WaitForChild("Input")
local YesButton = YesNoFrame.YesButton
local NoButton = YesNoFrame.NoButton
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
    if Index == #Dialog and ProximityPrompt:GetAttribute('Challenger') then
        local Tween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.1, 0, 0.5, 0)
        })
        Tween:Play()

        --when tween is done. connect functionality to the buttons
        Tween.Completed:Connect(function()
            local YesButtonClickConnection
            local NoButtonClickConnection
            local LastInputButtonClickConnection

            YesButtonClickConnection = YesButton.MouseButton1Click:Connect(function()
                --end gradual text
                GradualTextInProgress = false

                --disconnect connections
                if YesButtonClickConnection then
                    YesButtonClickConnection:Disconnect()
                end

                if NoButtonClickConnection then
                    NoButtonClickConnection:Disconnect()
                end

                --tween out both dialog and yesno frames
                local DialogTween = TweenService:Create(DialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 2, 0)
                })

                local YesNoTween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 2, 0)
                })
                DialogTween:Play()
                YesNoTween:Play()
                
                --need to tween out yes no frame if dialog is exhausted through input button
                
                --fire the event to transport player to the game
                ProximityPrompt.Enabled = true
                DialogOpen = false
                DialogIndex = 0
                Player.Character.HumanoidRootPart.Anchored = false

                ChallengeEvent:FireServer(ProximityPrompt)

            end)

            --handle the no button behavior. 
            NoButtonClickConnection = NoButton.MouseButton1Click:Connect(function()
            
                --end gradual text
                GradualTextInProgress = false

                --disconnect connections
                if YesButtonClickConnection then
                    YesButtonClickConnection:Disconnect()
                end

                if NoButtonClickConnection then
                    NoButtonClickConnection:Disconnect()
                end

                --tween out both dialog and yesno frames
                local DialogTween = TweenService:Create(DialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 2, 0)
                })

                local YesNoTween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 2, 0)
                })
                DialogTween:Play()
                YesNoTween:Play()

                ProximityPrompt.Enabled = true
                DialogOpen = false
                DialogIndex = 0
                
                Player.Character.HumanoidRootPart.Anchored = false
            end)
        end)
    end
    
    if Dialog[Index] then
        --display dialog text at the page spot
        GradualText(Dialog[Index])
    
    else
        --if the tween exists then cancel
        if DialogTween then
            DialogTween:Cancel()
            DialogTween = nil
        end
        --tween the dialog frame out when dialog is exhausted.
        local Tween = TweenService:Create(DialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 2, 0)
        })
        DialogTween = Tween
        DialogTween:Play()

        --tween YesNoFrame disconnect 
        local YesNoTween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 2, 0)
        })
        YesNoTween:Play()

        ProximityPrompt.Enabled = true
        DialogOpen = false
        DialogIndex = 0
        Player.Character.HumanoidRootPart.Anchored = false
    end
end

--in future use context action service space bar also consider mobile. human computer interaction! future feature.
InputButton.MouseButton1Click:Connect(function()
    if GradualTextInProgress then
        return
    end

    local Dialog = DialogModule[NPCName.Value] 
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
