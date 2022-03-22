print("Shop script started")
local InvFunctions = require(script.Parent:WaitForChild("Inventory"):WaitForChild("functions"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local ShopGUI = Player:WaitForChild("PlayerGui",1):WaitForChild("UniqueOpenGui",1):WaitForChild("MenuGui",1):WaitForChild("ShopContainer",1)
local AccessoryList = ShopGUI:WaitForChild("ShopScreen",1)
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories",1):WaitForChild("ShopTemplate",1)

local InventoryEvents = ReplicatedStorage:WaitForChild("RemoteEvents",1):WaitForChild("InventoryEvents",1)
local GetCurrencyEvent = InventoryEvents:WaitForChild("GetCurrencyEvent",1)
local SpendCurrencyEvent = InventoryEvents:WaitForChild("SpendCurrencyEvent",1)
local AccesoryTableEvent = InventoryEvents:WaitForChild("AddAccesoryTableEvent",1)
local ColorEvent = InventoryEvents:WaitForChild("ColorEvent")

local ShopMessage = ShopGUI:WaitForChild("ShopMessage",1)



local EquippedConnections = {}
local ButtonList = {}
local AccesoryTable = {}

local Selected
local Currency
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
local function addToFrame(AccessoryString)
    local newtemplate = Acctemplate:Clone()
    newtemplate.Name = AccessoryString.Name
    newtemplate.AccessoryName.Text = AccessoryString.Value
    newtemplate.Parent = AccessoryList
    local bool = false
    -- clones the accessory Object to add to button
    local newAccessory = AccessoryString.Accessory:Clone()
    newtemplate.Cost.Value = AccessoryString.Cost.Value
    newAccessory.Parent = newtemplate.ViewportFrame

    -- [[this is where the visual for the button is added]]
    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(newAccessory.Handle.Position + (newAccessory.Handle.CFrame.lookVector * 2),newAccessory.Handle.Position)
    camera.Parent = newtemplate.ViewportFrame

    newtemplate.ViewportFrame.CurrentCamera = camera

    if table.find(InvFunctions["InvData"], newtemplate.Name) then
        newtemplate.ImageColor3 = Color3.fromRGB(161,161,161)
        bool = true
    else
        newtemplate.ImageColor3 = Color3.fromRGB(68,172,94)
    end
    ButtonList[#ButtonList + 1] = newtemplate
    EquippedConnections[#EquippedConnections + 1] = newtemplate.Activated:Connect(function() 
        if bool == false then    
            Selected = newtemplate
        else
            ShopMessage.Text = "That Accessory is not available"
            wait(1)
            ShopMessage.Text = ""
        end
        print(newtemplate.Name .. " is selected")
        print(Selected.Name .. " Consistancy Check")
    end)


end
local function Populate(AccTable)
    if CheckForFire() then
        for key in pairs (AccTable) do
            for inst2 in pairs (AccTable[key]) do
                --Strings contain an Accessory Object
                addToFrame(AccTable[key][inst2])
            end
        end
    end
end
AccesoryTableEvent.OnClientEvent:Connect(Populate)

local function InventoryColorChanger()
    ColorEvent:FireServer(Selected.Name)
end

ShopGUI.BuyButton.Activated:Connect(function()
if Selected ~= nil then
    if not table.find(InvFunctions["InvData"], Selected.Name) then 
        GetCurrencyEvent:FireServer()
        wait(2)
        if Currency >= Selected.Cost.Value and Currency ~= nil then
            SpendCurrencyEvent:FireServer(Selected.Cost.Value)
            Selected.ImageColor3 = Color3.fromRGB(161,161,161)
            InvFunctions.AddItem(Selected)
            InventoryColorChanger()
            Selected = nil
        end
    end

else
    ShopMessage.Text = "Please select an accessory to purchase"
    wait(5)
    ShopMessage.Text = ""
end
end)
local function setCurrency(PlayerMoney)
    Currency = PlayerMoney
end
GetCurrencyEvent.onClientEvent:Connect(setCurrency)

