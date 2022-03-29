--services used
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
--UFX elements 
local MenuGui = Player:WaitForChild("PlayerGui"):WaitForChild("UniqueOpenGui"):WaitForChild("MenuGui")
local InventoryGUI = MenuGui:WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("TabContainer"):WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TabContainer"):WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("TabContainer"):WaitForChild("ZFrame")
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories"):WaitForChild("Template")
local AccessoryTab = InventoryGUI:WaitForChild("ALabel")
local TitleTab = InventoryGUI:WaitForChild("TLabel")
local BadgeTab = InventoryGUI:WaitForChild("ZLabel")
--Remote Events to be Used
local InventoryEvents = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents")
local AccesoryTableEvent = InventoryEvents:WaitForChild("AddAccesoryTableEvent")
local GetPlayerSavedInventoryEvent = InventoryEvents:WaitForChild("InventoryStore")
local SendServerEquipped = InventoryEvents:WaitForChild("SendEquippedToServer")
local SendToServer = InventoryEvents:WaitForChild("InventorySave")
local ColorEvent = InventoryEvents:WaitForChild("ColorEvent")
--Module Scripts to be used
local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))
local InvFunctions = require(script.parent:WaitForChild("Inventory"):WaitForChild("functions"))


local EquippedConnections = {} -- for button activations
local ButtonList = {} -- modifies image Buttons
AccesoryTable = {}

local function CheckForFire()
    local i =  0
    while not AccesoryTable do
        print(AccesoryTable)
        wait(1)
        i = i+1
        if i == 10 then
            return 0
        end
    end
    return true
end

-- mode in this case is used to determine if the accessory is equipped, not equipped and not available
local function ChangeColor(Accessory, mode)
    local arrayloc = table.find(ButtonList,Accessory)
    if mode == 1 then
    ButtonList[arrayloc].ImageColor3 = Color3.fromRGB(68,172,94)
    elseif mode == 2 then
        ButtonList[arrayloc].ImageColor3 = Color3.fromRGB(73,88,172)
    else
        ButtonList[arrayloc].ImageColor3 = Color3.fromRGB(161,161,161)
    end
end

-- this is adds buttons to the list based on the AccessoryList contents
local function addToFrame(AccessoryString, Type)
    local newtemplate = Acctemplate:Clone()
    newtemplate.Name = AccessoryString.Name
    newtemplate.AccessoryName.Text = AccessoryString.Value
    newtemplate.Parent = AccessoryList
    local bool = false
    local equipped = false
    -- clones the accessory Object to add to button
    local newAccessory = AccessoryString.Accessory:Clone()
    newAccessory.Parent = newtemplate.ViewportFrame

    -- [[this is where the visual for the button is added]]
    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(newAccessory.Handle.Position + (newAccessory.Handle.CFrame.lookVector * 2),newAccessory.Handle.Position)
    camera.Parent = newtemplate.ViewportFrame

    newtemplate.ViewportFrame.CurrentCamera = camera

    if not table.find(InvFunctions["InvData"], newtemplate.Name) then
        newtemplate.ImageColor3 = Color3.fromRGB(161,161,161)
    else
        bool = true
        newtemplate.ImageColor3 = Color3.fromRGB(68,172,94)
    end
    ButtonList[#ButtonList + 1] = newtemplate
    EquippedConnections[#EquippedConnections + 1] = newtemplate.Activated:Connect(function()     
        --current placeholder for updating Button bool. I.E. Checks for if InvFunctions["InvData"] updated to have
        if not bool then
            
            if table.find(InvFunctions["InvData"], newtemplate.Name ) then
                bool = true
                ChangeColor(newtemplate,2)
            end
        end
        if bool then
            local success, errorMessage = pcall(function()
            SendServerEquipped:InvokeServer(AccessoryString.Accessory, Type)
            end)
            if success then
                print("Accessory Button called")
                return
            else
                print("Error" .. errorMessage)
         end
         if equipped == false then
            equipped = true
            ChangeColor(newtemplate, 2)
         else
            equipped = false
            ChangeColor(newtemplate,1)
         end
        end
    end)


end



--populates the Accesory Scrolling Frame with all the items 
local function Populate(AccTable)
    
    if CheckForFire() then
        for key in pairs (AccTable) do
            for inst2 in pairs (AccTable[key]) do
                --Strings contain an Accessory Object
                addToFrame(AccTable[key][inst2], key)
            end
        end
    end
end
--[[
    make sure when using AddItem that the Button Will be Disabled in the Shop GUI Note for Self 
    or other team member. these are test buttons to add Accessories. Find the Accessory you wish to add to the Player from the Accessory List
]]
--[[InventoryGUI:WaitForChild("AddAll").Activated:Connect(function()
    local Button
    for key, value in pairs (AccessoryList:GetChildren()) do
        if value:IsA("ImageButton") then
     Button = value
     InvFunctions.AddItem(Button)
            ChangeColor(Button,1)
        end
    end
    
    --a disable or hide button would go here
    InventoryGUI.AddAll:Destroy()
end)]]

InventoryGUI:WaitForChild("ExitButton").Activated:Connect(function()
    GuiUtilities.TweenCurrentFrameOut(InventoryGUI)
end)

--fires Script on event passing player and AccessoryTable to target function
AccesoryTableEvent.OnClientEvent:Connect(Populate)


--stores saved inventory into InvFunctions table functions["InvData"]
GetPlayerSavedInventoryEvent.OnClientEvent:Connect(InvFunctions.store)
local function Send()
    SendToServer:FireServer(InvFunctions["InvData"])
end
SendToServer.OnClientEvent:Connect(Send)

AccessoryTab.Button.Activated:Connect(function()
    AccessoryTab.Button.BackgroundTransparency = 0.85
    TitleTab.Button.BackgroundTransparency = 0.97
    BadgeTab.Button.BackgroundTransparency = 0.97
TitleList.Visible = false
BadgeList.Visible = false
AccessoryList.Visible = true
end)

TitleTab.Button.Activated:Connect(function()
    TitleTab.Button.BackgroundTransparency = 0.85
    AccessoryTab.Button.BackgroundTransparency = 0.97
    BadgeTab.Button.BackgroundTransparency = 0.97
TitleList.Visible = true
BadgeList.Visible = false
AccessoryList.Visible = false
end)

BadgeTab.Button.Activated:Connect(function()
    BadgeTab.Button.BackgroundTransparency = 0.85
    AccessoryTab.Button.BackgroundTransparency = 0.97
    TitleTab.Button.BackgroundTransparency = 0.97
TitleList.Visible = false
BadgeList.Visible = true
AccessoryList.Visible = false
end)

local function ShopTrigger(ItemName)
    local Button
    for key, value in pairs (AccessoryList:GetChildren()) do
        if value.Name == ItemName then
        Button = value
            ChangeColor(Button,1)
        end
    end
end
ColorEvent.onClientEvent:Connect(ShopTrigger)

