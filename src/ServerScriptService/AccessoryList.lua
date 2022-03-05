local Accessories = {}
Accessories.Type = {
    ["Head"] = {
        game.ReplicatedStorage.Accessories.HeadTest;

    };

    ["Body"] = {
        game.ReplicatedStorage.Accessories.BodyTest;

    };

    ["Arms"] = {
        game.ReplicatedStorage.Accessories.ArmTest;

    };

    ["Legs"] = {
        game.ReplicatedStorage.Accessories.LegTest;

    };

}

Accessories.EquipItem = function(AcceID,Type)
    local AccessoryTable = Accessories.Type[Type]
    local Equipping = AccessoryTable[AcceID]
    return Equipping
end

return Accessories