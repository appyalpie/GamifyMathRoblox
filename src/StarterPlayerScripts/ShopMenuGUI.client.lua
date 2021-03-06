script.Disabled = true -- Moved to Inventory 2.0
if script.Disabled == true then
    print("Moved to Inventory 2.0 (ShopMenuGUI.client.lua")
else
local InvFunctions = require(script.Parent:WaitForChild("Inventory"):WaitForChild("functions"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local MenuGui = Player:WaitForChild("PlayerGui"):WaitForChild("UniqueOpenGui"):WaitForChild("MenuGui")
local ShopGUI = MenuGui:WaitForChild("ShopContainer")
local AccessoryList = ShopGUI:WaitForChild("ShopScreen")
local Acctemplate = ReplicatedStorage:WaitForChild("Accessories"):WaitForChild("ShopTemplate")
local GuiUtilities = require(ReplicatedStorage:WaitForChild("GuiUtilities"))

local InventoryEvents = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InventoryEvents")
local GetCurrencyEvent = InventoryEvents:WaitForChild("GetCurrencyEvent")
local SpendCurrencyEvent = InventoryEvents:WaitForChild("SpendCurrencyEvent")
local AccesoryTableEvent = InventoryEvents:WaitForChild("AddAccesoryTableEvent")
local ColorEvent = InventoryEvents:WaitForChild("ColorEvent")
local OpenShopEvent = InventoryEvents:WaitForChild("OpenShopEvent")

local ShopMessage = ShopGUI:WaitForChild("ShopMessage")

local otherFrames = {MenuGui:WaitForChild("OptionsMenu");MenuGui:WaitForChild("PortalMenu");MenuGui:WaitForChild("InventoryScreen")}

local EquippedConnections = {}
local ButtonList = {}
local AccesoryTable = {}

local Selected -- pointer to a specific Accessory image Button 
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
--Similar to Inventoies addToFrame only diffrence is this registers the cost of Accessories
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
        if table.find(InvFunctions["InvData"], newtemplate.Name) then -- checks to make sure if it is already owned again
            bool = true
        end 
        if bool == false then    
            Selected = newtemplate
        else
            ShopMessage.Text = "That Accessory is not available"
            wait(5)
            ShopMessage.Text = ""
        end
        ShopMessage.Text = newtemplate.AccessoryName.Text .. " is selected"
        wait(1)
        ShopMessage.Text = "The Cost of " .. newtemplate.AccessoryName.Text  .. " is : " .. newtemplate.Cost.Value .. " credits" -- change this to whatever currency name we want to use
        
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
    ShopMessage.Text = "Please select an accessory to purchase"
end
AccesoryTableEvent.OnClientEvent:Connect(Populate)

local function InventoryColorChanger()
    ColorEvent:FireServer(Selected.Name)
end

ShopGUI.BuyButton.Activated:Connect(function()
if Selected ~= nil then
    if not table.find(InvFunctions["InvData"], Selected.Name) then 
        GetCurrencyEvent:FireServer()
        ShopGUI.BuyButton.Active = false -- to prevent repeated purcahse attempts
        wait(2)
        if Currency >= Selected.Cost.Value and Currency ~= nil then
            SpendCurrencyEvent:FireServer(Selected.Cost.Value)
            Selected.ImageColor3 = Color3.fromRGB(161,161,161)
            InvFunctions.AddItem(Selected)
            InventoryColorChanger()
            Selected = nil
        end
        ShopGUI.BuyButton.Active = true -- brings button back
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

local function OpenShop()
    GuiUtilities.TweenOtherActiveFramesOut(otherFrames)
    GuiUtilities.TweenInCurrentFrame(ShopGUI)
end

ShopGUI.ExitButton.Activated:Connect(function()
    GuiUtilities.TweenCurrentFrameOut(ShopGUI)
end)
-- open shop event was created if the Shop event is server fired otherwise interaction will need to be added to fire the same function

OpenShopEvent.onClientEvent:Connect(OpenShop)
end