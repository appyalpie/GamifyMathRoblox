


local InvFunctions = require(script.parent:WaitForChild("Inventory"):WaitForChild("functions"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local InventoryGUI = Player:WaitForChild("PlayerGui"):WaitForChild("InventoryGUI"):WaitForChild("InventoryScreen")
local AccessoryList = InventoryGUI:WaitForChild("AFrame")
local TitleList = InventoryGUI:WaitForChild("TFrame")
local BadgeList = InventoryGUI:WaitForChild("ZFrame")
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories"):WaitForChild("Template")
local InventoryEvents = ReplicatedStorage:WaitForChild("RemoteEvents",5):WaitForChild("InventoryEvents",5)
local AccesoryTableEvent = InventoryEvents:WaitForChild("AddAccesoryTableEvent",1)
local GetPlayerSavedInventoryEvent = InventoryEvents:WaitForChild("InventoryStore",1)
local SendServerEquipped = InventoryEvents:WaitForChild("SendEquippedToServer",1)
local SendToServer = InventoryEvents:WaitForChild("InventorySave",1)

local EquippedConnections = {}
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



-- this is adds buttons to the list based on the AccessoryList contents
local function addToFrame(AccessoryString, Type)
    local newtemplate = Acctemplate:Clone()
    newtemplate.Name = AccessoryString.Name
    newtemplate.AccessoryName.Text = AccessoryString.Name
    newtemplate.Parent = AccessoryList
    local bool = false
    -- clones the accessory Object to add to button
    local newAccessory = AccessoryString.Accessory:Clone()
    newAccessory.Parent = newtemplate.ViewportFrame

    -- [[this is where the visual for the button is added]]
   
    --local camera = Instance.new("Camera")
    --camera.CFrame = CFrame.new(newAccessory.PrimaryPart.Position + (newAccessory.PrimaryPart.CFrame.lookVector * 2),newAccessory.PrimaryPart.Position)
    --camera.Parent = newtemplate.ViewportFrame

    --newtemplate.ViewportFrame.CurrentCamera = camera

   

    EquippedConnections[#EquippedConnections + 1] = newtemplate.Activated:Connect(function()     
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
        end
        --current placeholder for updating Button bool. I.E. Checks for if InvFunctions["InvData"] updated to have
        for keys in pairs(InvFunctions["InvData"]) do
            if newtemplate.AccessoryName.Text == InvFunctions["InvData"][keys] then
                bool = true
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
InventoryGUI:WaitForChild("HeadTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("HeadTest")
    InvFunctions.AddItem(Button)
    --a disable or hide button would go here
    InventoryGUI.HeadTest:Destroy()
end)
InventoryGUI:WaitForChild("BodyTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("BodyTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.BodyTest:Destroy()
end)
InventoryGUI:WaitForChild("LegTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("LegsTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.LegTest:Destroy()
end)
InventoryGUI:WaitForChild("ArmTest").Activated:Connect(function()
    local Button = AccessoryList:FindFirstChild("ArmsTest")
    InvFunctions.AddItem(Button)

    InventoryGUI.ArmTest:Destroy()
end)





InventoryGUI:WaitForChild("CloseButton").Activated:Connect(function()
    InventoryGUI.Parent.Enabled = false
end)

--fires Script on event passing player and AccessoryTable to target function
AccesoryTableEvent.OnClientEvent:Connect(Populate)


--stores saved inventory into InvFunctions table functions["InvData"]
GetPlayerSavedInventoryEvent.OnClientEvent:Connect(InvFunctions.store)
local function Send()
    SendToServer:FireServer(InvFunctions["InvData"])
end
SendToServer.OnClientEvent:Connect(Send)
