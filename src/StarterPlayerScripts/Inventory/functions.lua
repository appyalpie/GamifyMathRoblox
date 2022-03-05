local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",5):WaitForChild("InventoryStore",5)
local functions = {}
-- reformated so scoping won't get confusing
functions["inventory"] = {
    
        Items = {
           
                ACH1 = Instance.new("BoolValue"),
                ACA1 = Instance.new("BoolValue"),
                ACL1 = Instance.new("BoolValue"),
                ACB1 = Instance.new("BoolValue")
            
        },
        Equipped = {
            
                ["Head"] = {},
                ["Legs"] = {},
                ["Arms"] = {},
                ["Body"] = {}
            
        },
        First = true
    
}
functions["InvData"] = {}
-- Inventory Table Constructor and attach to player
 function functions.new(DataFromStore)
    local InventoryData = {}
    print("new was called")
    print(DataFromStore)
    setmetatable(InventoryData, functions["inventory"])
    InventoryData.Items.ACH1.Name = "Accesory A"
    InventoryData.Items.ACA1.Name = "Accesory B"
    InventoryData.Items.ACL1.Name = "Accesory C"
    InventoryData.Items.ACB1.Name = "Accesory D"
    InventoryData.Items.ACH1.Value = false
    InventoryData.Items.ACA1.Value = false
    InventoryData.Items.ACL1.Value = false
    InventoryData.Items.ACB1.Value = false

    

    if not DataFromStore == nil then
        for _, inst in pairs(InventoryData.Items) do
            InventoryData.Items[inst].Value = DataFromStore[inst].Value
        end
    end
    return InventoryData
end


-- check if first time initalizing inventory
-- Player should be the data table
function functions.Exist(InventoryData)
    if InventoryData.First == false then
        return true
    end
    return false
end
-- adds item to player inventory
function functions.AddItem(InventoryData, Item)
    for _, inst in pairs(InventoryData.Items) do
        if InventoryData.Items[inst].Name == Item then
            InventoryData.Items[inst].Value = true
            break
        end
    end
end
--Rework----------------------------------------------------------------------
--equips item in player inventory
function functions.EquipItem(InventoryData, Item, Type)
    for _, inst in pairs(InventoryData.Equipped) do
        if InventoryData.Equipped[inst].Name == Item then
            if not Type then
                break
            else
                functions.UnEquipItem(InventoryData, Type)
                Type = InventoryData.Items[inst].Name
                break
            end
        end
    end
end
    --unequips item from player
    function functions.UnEquipItem(InventoryData, Type)
        print(InventoryData)
        for _, inst in pairs(InventoryData.Equipped) do
            if InventoryData.Equipped[inst].Name == Type then
                InventoryData.Equipped[inst] = nil
            end
        end
    end

    --[[ pending title functionality
    function Inventory.AddTitle(InventoryData,Title)
    end 
    ]]
    -- displays the items description as a function
    function functions.DisplayDescription()
        print("Display Description worked")
    end
    --an edit may need to happen here in the event storing data does not work
    --creates a save table to send to DataStore under InvData as key
    function functions.Save(InventoryData)
        local DataToStore = {}
        for _, inst in pairs(InventoryData.Items) do
            table.insert(DataToStore, InventoryData.Items[inst].Value)
        end
        --unequips all equipped items
        for _, inst in pairs(InventoryData.Equipped) do
            InventoryData.Equipped[inst] = nil
        end
        return DataToStore
    end
    --resets Inventory as a function
    function functions.Reset(InventoryData)
        for _, inst in pairs(InventoryData.Items) do
            InventoryData.Items[inst].Value = false
        end
    end
    function functions.store(InvDat)
        functions["InvData"] = InvDat
        return functions["InvData"]
    end
    function functions.get()
        return functions["InvData"]
    end
    remoteEvent.OnClientEvent:Connect(functions.new)
    return functions

