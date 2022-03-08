local AccessoriesList = {}

AccessoriesList.Type = {
    ["Head"] = {
        [1] = game.ReplicatedStorage.Accessories.HeadTest;
        --[2] = game.ReplicatedStorage.Accessories.MathBlockHead;
    };

    ["Body"] = {
        [1] = game.ReplicatedStorage.Accessories.BodyTest;

    };

    ["Arms"] = {
        [1] = game.ReplicatedStorage.Accessories.ArmsTest;

    };

    ["Legs"] = {
        [1] = game.ReplicatedStorage.Accessories.LegsTest;

    };

}

AccessoriesList.GetAccesory = function()
    return AccessoriesList.Type
end

return AccessoriesList