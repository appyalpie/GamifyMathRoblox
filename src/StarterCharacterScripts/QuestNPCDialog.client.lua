--bring in services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DialogModule = require(ReplicatedStorage.DialogModule)
local Player = game:GetService("Players").LocalPlayer

local PortalGuiUpdateIsland3BE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("BarrierAndPortalEvents"):WaitForChild("PortalGuiUpdateIsland3BE")
local UpdateIsland3BarrierDownStatusRE = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Island_3"):WaitForChild("BarrierAndPortalEvents"):WaitForChild("UpdateIsland3BarrierDownStatusRE")

--GUI variables
local DialogFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog"):WaitForChild("DialogFrame")
local YesNoFrame = Player:WaitForChild("PlayerGui"):WaitForChild("Dialog"):WaitForChild("YesNoFrame")
local InputButton =  DialogFrame:WaitForChild("Input")
local YesButton = YesNoFrame.YesButton
local NoButton = YesNoFrame.NoButton
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("Island3GUI"):WaitForChild("IngredientFrame")
--this is the NPC name label in the dialog frame maybe not correct
local NPCName = DialogFrame:WaitForChild("NPCName")
local NPCState = "Randallf_first_meeting"
local QuestNPCs = game.Workspace.QuestNPCs
local InputButtonConnection

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
--fast text
local function FastText(Text)
    DialogFrame.DialogText.Text = Text
end

--handle dialog given proximity prompt. bring in dialog associated with individual NPC base on dialog module script
local function OnDialog(Dialog, Index, ProximityPrompt)
    --make the inventory GUI invisible. then make it visible when done
    InventoryGUI.Visible = false
    --do this once the dialog is exhausted 
    if Index == #Dialog then
    

        if ProximityPrompt:GetAttribute("QuestCompleted") then --handles situation where player already completed the quest
            print("Quest Completed")

        elseif ProximityPrompt:GetAttribute("FirstMeetingComplete") then --handle if the quest has been accepted but not completed
            --name of potion is  "GrowPotion"
            if Player.Backpack:FindFirstChild("GrowPotion") or game.Workspace:WaitForChild(Player.Name):FindFirstChild("GrowPotion") then --handle if player accepted quest and obtained quest key item (completed)
                
                --tween in yes no 
                local Tween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.1, 0, 0.5, 0)
                })
                Tween:Play()
        
                --when tween is done. connect functionality to the buttons
                Tween.Completed:Connect(function()

                    local YesButtonClickConnection
                    local NoButtonClickConnection
        
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
                        
                        --set QuestCompleted flag and unlock the barrier. later place for animation?
                        ProximityPrompt:SetAttribute("QuestCompleted", true)
                        local Barrier = game.Workspace.Island_3.Barrier

                        if Barrier:FindFirstChild("Barrier_Part") then
                            Barrier.Barrier_Part:Destroy()
                            Barrier.BeamHolder.Attachment0.Beam.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 194, 23)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 194, 23))
                            }
                        end
                        --also decrement the potion from players backpack or their hand if it's in their hand
                        if game.Workspace:WaitForChild(Player.Name):FindFirstChild("GrowPotion") then
                            game.Workspace:WaitForChild(Player.Name):FindFirstChild("GrowPotion"):Destroy()
                        elseif Player.Backpack:FindFirstChild("GrowPotion") then
                            Player.Backpack:FindFirstChild("GrowPotion"):Destroy()
                        end

                        -- Update the Portal GUI and Update the player's Barrier Status
                        PortalGuiUpdateIsland3BE:Fire(true)
                        UpdateIsland3BarrierDownStatusRE:FireServer()
                        --cleanup
                        InputButtonConnection:Disconnect()
                        ProximityPrompt.Enabled = true
                        DialogOpen = false
                        DialogIndex = 0
                        Player.Character.HumanoidRootPart.Anchored = false
                        --get the inventory window back
                        InventoryGUI.Visible = true
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
        
                        --cleanup
                        InputButtonConnection:Disconnect()
                        ProximityPrompt.Enabled = true
                        DialogOpen = false
                        DialogIndex = 0
                        --release the player
                        Player.Character.HumanoidRootPart.Anchored = false
                        --get the inventory window back
                        InventoryGUI.Visible = true
                    end)
                end)
                
            else
                print("test")
            end
            
        else
            --accept deny quest logic here. change the yes no buttons to accept/deny
            YesButton.Text = "Accept"
            NoButton.Text = "Deny"
            --tween yes/no frame. connect y/n button
            local Tween = TweenService:Create(YesNoFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.1, 0, 0.5, 0)
                
            })
            Tween:Play()
    
            --when tween is done. connect functionality to the buttons
            Tween.Completed:Connect(function()

                local YesButtonClickConnection
                local NoButtonClickConnection
    
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
                    
                    --switch the flag 
                    ProximityPrompt:SetAttribute("FirstMeetingComplete", true)

                    --cleanup
                    --change yes/no button back
                    YesButton.Text = "Yes"
                    NoButton.Text = "No"

                    InputButtonConnection:Disconnect()
                    ProximityPrompt.Enabled = true
                    DialogOpen = false
                    DialogIndex = 0
                    Player.Character.HumanoidRootPart.Anchored = false
                    --get the inventory window back
                    InventoryGUI.Visible = true
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
    
                    InputButtonConnection:Disconnect()
                    ProximityPrompt.Enabled = true
                    DialogOpen = false
                    DialogIndex = 0
                    --release the player
                    Player.Character.HumanoidRootPart.Anchored = false
                    --get the inventory window back
                    InventoryGUI.Visible = true
                end)
            end)
        end
    end
    
    if Dialog[Index] then
        --display dialog text in the frame
        FastText(Dialog[Index])

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

        InputButtonConnection:Disconnect()
        ProximityPrompt.Enabled = true
        DialogOpen = false
        DialogIndex = 0
        Player.Character.HumanoidRootPart.Anchored = false
        InventoryGUI.Visible = true
    end
end

--loop through npcs in NPCs directory
for _, v in pairs(QuestNPCs:GetChildren()) do
    local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
    local ProximityPrompt = HumanoidRootPart:FindFirstChild("ProximityPrompt")

    if HumanoidRootPart and ProximityPrompt then
        
        ProximityPrompt.Triggered:Connect(function()
            if DialogOpen then

                return
            end
            
            --in future use context action service space bar. Hhuman computer interaction! future feature.
            
            InputButtonConnection = InputButton.MouseButton1Click:Connect(function()
                local Dialog = DialogModule[NPCState] 
                if GradualTextInProgress then
                    return
                end
                
                Dialog = DialogModule[NPCState] 
                DialogIndex += 1
                print(NPCName.Value)
                OnDialog(Dialog, DialogIndex, QuestNPCs[NPCName.Value].HumanoidRootPart.ProximityPrompt)          
            end)

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


            if ProximityPrompt:GetAttribute("QuestCompleted") then
                NPCState = "Randallf_fourth_meeting"

            elseif ProximityPrompt:GetAttribute("FirstMeetingComplete") then
                if Player.Backpack:FindFirstChild("potion") then
                    --need name of potion, temporary hard code as "potion"
                    NPCState = "Randallf_third_meeting"
                    --tween in yes no as a give/keep and connect
                else
                    --tween out dialog
                    NPCState = "Randallf_second_meeting" 
                end
            else
                NPCState = "Randallf_first_meeting"
            end 
            
            DialogIndex = 1
            local Dialog = DialogModule[NPCState]
            OnDialog(Dialog, DialogIndex, ProximityPrompt)
        end)
    end
end
