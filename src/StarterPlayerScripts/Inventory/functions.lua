
    -- reformated so scoping won't get confusing
    local inventory = {
        Items = {
            ACH1 = Instance.new("BoolValue"),
            ACA1 = Instance.new("BoolValue"),
            ACL1 = Instance.new("BoolValue"),
            ACB1 = Instance.new("BoolValue")        
        },
        Equipped = {
            ["Head"] = {},
            ["Legs"]  = {},
            ["Arms"] = {},
            ["Body"] = {}
        }
    }




function Inventory.new(Player,DataFromStore)
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


    if not DataFromStore then
       table.insert(Player,InventoryData)
    else
        for _,inst in pairs (InventoryData.Items) do
            InventoryData.Items[inst].Value = DataFromStore.Value
        end
        table.insert(Player,InventoryData)

    end


end

function Inventory.Exist(Player)
    if Player.Inventory.First == false then
        return true
    end
    return false
end

function Inventory.AddItem(Player,Item)
    local InventoryData = Player.Inventory
    for _, inst in pairs (InventoryData.Items) do
        if InventoryData.Items(inst).Name == Item then
            InventoryData.Items(inst).Value = true
            break
        end
    end

end
function Inventory.EquipItem(Player,Item,Type)
    local InventoryData = Player.Inventory
    for _, inst in pairs (InventoryData.Equipped) do
        if InventoryData.Equipped(inst).Name == Item then
            if not Type then
                
                break
            else
                Inventory.UnEquipItem(Player,Type)
                Type = InventoryData.Items(inst).Name
                break
        end
    end 
end

function Inventory.UnEquipItem(Player,Type)
    local InventoryData = Player.Inventory
    for _,inst in pairs (InventoryData.Equipped) do
        if InventoryData.Equipped(inst).Name == Type then
            InventoryData.Equipped(inst) = nil
            break
        end
    end
end   

--[[ pending title functionality
function Inventory.AddTitle(Player,Title)

end 
]]
function Inventory.DisplayDescription(Item)

end   
--an edit may need to happen here in the event storing data does not work
function Inventory.Save(Player)
    local InventoryData = Player.Inventory
    local DataToStore = {}
    for _,inst in pairs (InventoryData.Items) do
        table.insert(DataToStore,InventoryData.Items(inst).Value)
    end
--unequips all equipped items
    for _,inst in pairs (InventoryData.Equipped) do
        InventoryData.Equipped(inst) = nil
    end
    return DataToStore
end

function Inventory.Reset(Player)
    local InventoryData = Player.Inventory
    for _, inst in pairs (InventoryData.Items) do
        InventoryData.Items(inst).Value = false
    end
end
