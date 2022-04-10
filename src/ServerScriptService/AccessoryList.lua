local AccessoriesList = {}

AccessoriesList.Type = {
    ["Head"] = {
        [1] = game.ReplicatedStorage.Accessories.MathBlockHead;
        [2] = game.ReplicatedStorage.Accessories.Goggles;
    };

    ["Body"] = {
        [1] = game.ReplicatedStorage.Accessories.BackPack;
        [2] = game.ReplicatedStorage.Accessories.Card24;
    };

    ["Arms"] = {
        [1] = game.ReplicatedStorage.Accessories.PetBlock;
        [2] = game.ReplicatedStorage.Accessories.WristWatch;
    };

    ["Legs"] = {
        [1] = game.ReplicatedStorage.Accessories.MathBlockKneeCover;
        [2] = game.ReplicatedStorage.Accessories.TwoDeckKneeCover;
    };

}

AccessoriesList.GetAccesory = function()
    return AccessoriesList.Type
end

return AccessoriesList