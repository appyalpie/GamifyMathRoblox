local AccessoriesList = {}
AccessoriesList.Type = {
    ["Head"] = {
        game.ReplicatedStorage.Accessories.HeadTest;

    };

    ["Body"] = {
        game.ReplicatedStorage.Accessories.BodyTest;

    };

    ["Arms"] = {
        game.ReplicatedStorage.Accessories.ArmsTest;

    };

    ["Legs"] = {
        game.ReplicatedStorage.Accessories.LegsTest;

    };

}

AccessoriesList.EquipItem = function(AcceID,Type)
    local AccessoryTable = AccessoriesList.Type[Type]
    local Equipping = AccessoryTable[AcceID]
    return Equipping
end

return AccessoriesList