    -- reformated so scoping won't get confusing
    local inventory = {
        __index ={
        Items = {
            __index ={
            ACH1 = Instance.new("BoolValue"),
            ACA1 = Instance.new("BoolValue"),
            ACL1 = Instance.new("BoolValue"),
            ACB1 = Instance.new("BoolValue")  
            }      
        },
        Equipped = {
            __index = {
            ["Head"] = {},
            ["Legs"]  = {},
            ["Arms"] = {},
            ["Body"] = {}
            }
        },
        First = true
    }
}



-- Inventory Table Constructor and attach to player
function Inventory.new(DataFromStore)
    local InventoryData = {}
    setmetatable(InventoryData, inventory)
    InventoryData.Items.ACH1.Name = "Accesory A"
    InventoryData.Items.ACA1.Name = "Accesory B"
    InventoryData.Items.ACL1.Name = "Accesory C"
    InventoryData.Items.ACB1.Name = "Accesory D"
    InventoryData.Items.ACH1.Value = false
    InventoryData.Items.ACA1.Value = false
    InventoryData.Items.ACL1.Value = false
    InventoryData.Items.ACB1.Value = false


    if not DataFromStore == nil then
        for _,inst in pairs (InventoryData.Items) do
           InventoryData.Items[inst].Value = DataFromStore[inst].Value
        end
    end
    return InventoryData
    
end



-- check if first time initalizing inventory
-- Player should be the data table
function Inventory.Exist(InventoryData)
    if InventoryData.First == false then
        return true
    end
    return false
end
-- adds item to player inventory
function Inventory.AddItem(InventoryData,Item)
    for _, inst in pairs (InventoryData.Items) do
        if InventoryData.Items[inst].Name == Item then
            InventoryData.Items[inst].Value = true
            break
        end
    end

end
--Rework----------------------------------------------------------------------
--equips item in player inventory
function Inventory.EquipItem(InventoryData,Item,Type)
    for _, inst in pairs (InventoryData.Equipped) do
        if InventoryData.Equipped[inst].Name == Item then
            if not Type then
                
                break
            else
                Inventory.UnEquipItem(InventoryData,Type)
                Type = InventoryData.Items[inst].Name
                break
        end
    end 
end
--unequips item from player 
function Inventory.UnEquipItem(InventoryData,Type)
    for _,inst in pairs (InventoryData.Equipped) do
        if InventoryData.Equipped[inst].Type == Type then
            InventoryData.Equipped[inst] = nil
        end
    end
end   

--[[ pending title functionality
function Inventory.AddTitle(InventoryData,Title)

end 
]]
-- displays the items description as a function
function Inventory.DisplayDescription(Item)

end   
--an edit may need to happen here in the event storing data does not work
--creates a save table to send to DataStore under InvData as key
function Inventory.Save(InventoryData)
    local DataToStore = {}
    for _,inst in pairs (InventoryData.Items) do
        table.insert(DataToStore,InventoryData.Items(inst).Value)
    end
--unequips all equipped items
    for _,inst in pairs (InventoryData.Equipped) do
        InventoryData.Equipped[inst] = nil
    end
    return DataToStore
end
--resets Inventory as a function
function Inventory.Reset(InventoryData)
    for _, inst in pairs (InventoryData.Items) do
        InventoryData.Items[inst].Value = false
    end
end
end