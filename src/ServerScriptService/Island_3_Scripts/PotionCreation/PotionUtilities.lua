local PotionUtilities = {}

local playerIngredientInventory = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdatePlayerIngredientGUIEvent = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("UpdatePlayerIngredientGUIEvent")

PotionUtilities.InitializePlayerIngredientInventory = function(player)
   playerIngredientInventory[player.UserId] = {
        Ingredient1 = 0;
        Ingredient2 = 0;
        Ingredient3 = 0
    }
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

------- Incrementing Ingredients -------

PotionUtilities.IncrementIngredient1 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient1"] = playerIngredientInventory[player.UserId]["Ingredient1"] + amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.IncrementIngredient2 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient2"] = playerIngredientInventory[player.UserId]["Ingredient2"] + amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.IncrementIngredient3 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient3"] = playerIngredientInventory[player.UserId]["Ingredient3"] + amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

------- Decrementing Ingredients -------

PotionUtilities.DecrementIngredients = function(player, ingredients)
    if ingredients["Ingredient1"] ~= nil then
        playerIngredientInventory[player.UserId]["Ingredient1"] = playerIngredientInventory[player.UserId]["Ingredient1"] - ingredients["Ingredient1"]
    end
    if ingredients["Ingredient2"] ~=nil then
        playerIngredientInventory[player.UserId]["Ingredient2"] = playerIngredientInventory[player.UserId]["Ingredient2"] - ingredients["Ingredient2"]
    end
    if ingredients["Ingredient3"] ~=nil then
        playerIngredientInventory[player.UserId]["Ingredient3"] = playerIngredientInventory[player.UserId]["Ingredient3"] - ingredients["Ingredient3"]
    end
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.DecrementIngredient1 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient1"] = playerIngredientInventory[player.UserId]["Ingredient1"] - amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.DecrementIngredient2 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient2"] = playerIngredientInventory[player.UserId]["Ingredient2"] - amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.DecrementIngredient3 = function(player, amount)
    playerIngredientInventory[player.UserId]["Ingredient3"] = playerIngredientInventory[player.UserId]["Ingredient3"] - amount
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end

PotionUtilities.GetPlayerIngredients = function(player)
    return playerIngredientInventory[player.UserId]
end

PotionUtilities.SetPlayerIngredients = function(player, playerIngredients)
    PotionUtilities.InitializePlayerIngredientInventory(player)
    playerIngredientInventory[player.UserId]["Ingredient1"] = playerIngredients["Ingredient1"]
    playerIngredientInventory[player.UserId]["Ingredient2"] = playerIngredients["Ingredient2"]
    playerIngredientInventory[player.UserId]["Ingredient3"] = playerIngredients["Ingredient3"]
    UpdatePlayerIngredientGUIEvent:FireClient(player, playerIngredientInventory[player.UserId])
end


return PotionUtilities