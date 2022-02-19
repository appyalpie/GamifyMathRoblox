local Inventory = {}
    Invnetory.Items = {}
        Inventory.Items.ACH1 = {}
            Inventory.Items.ACH1.Name = "Accessory A"
            Inventory.Items.ACH1.Has = false
        Inventory.Items.ACA1 = {}
            Inventory.Items.ACA1.Name = "Accessory B"
            Inventory.Items.ACA1.Has = false
        Inventory.Items.ACL1 = {}
            Inventory.Items.ACL1.Name = "Accessory C"
            Inventory.Items.ACL1.Has = false
        Inventory.Items.ACB1 = {}
            Inventory.Items.ACB1.Name = "Accessory D"
            Inventory.Items.ACB1.Has = false
Inventory.First = true

function Invnetory.new(Player,DataFromStore)
    local self = {}
    setmetatable(self,Inventory)
    if not DataFromStore then
       table.insert(Player,Inventory)
    end

    if not self.Exist(Player) then
        
        --attach to player here
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

function Invnetory.Save(Player)
    -- set the data table that is sent to data store here
end

function Invnetory.Reset(Player)
    local Inventory = Player.Invnetory
    for _, inst in pairs (Inventory.Items) do
        Inventory.Items(_).Has = false
    end
end
