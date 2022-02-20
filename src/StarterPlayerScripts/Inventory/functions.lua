
    -- reformated so scoping won't get confusing
    local Inventory = {
        Items = {
            ACH1 = Instance.new("BoolValue"),
            ACA1 = Instance.new("BoolValue"),
            ACL1 = Instance.new("BoolValue"),
            ACB1 = Instance.new("BoolValue")        
        }
    }




function Inventory.new(Player,DataFromStore)
    local inventory = {}
    setmetatable(inventory, Inventory)
    inventory.Items.ACH1.Name = "Accesory A"
    inventory.Items.ACA1.Name = "Accesory A"
    inventory.Items.ACL1.Name = "Accesory A"
    inventory.Items.ACB1.Name = "Accesory A"
    inventory.Items.ACH1.Value = false
    inventory.Items.ACA1.Value = false
    inventory.Items.ACL1.Value = false
    inventory.Items.ACB1.Value = false


    if not DataFromStore then
       table.insert(Player,Inventory)
    end


end

function Inventory.Exist(Player)
    if Player.Inventory.First == false then
        return true
    end
    return false
end

function Inventory.AddItem(Player,Item)
    local Inventory = Player.Invnetory
    for _, inst in pairs (Inventory.Items) do
        if Player.Inventory.Items(inst).Name == Item then
            Player.Inventory.Items(inst).Has = true
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

function Inventory.Save(Player)
    -- set the data table that is sent to data store here
end

function Inventory.Reset(Player)
    local Inventory = Player.Invnetory
    for _, inst in pairs (Inventory.Items) do
        Inventory.Items(_).Has = false
    end
end
