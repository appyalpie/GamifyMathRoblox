local RecipeList = {
    [1] = {
        Name = "Butt",
        Ingredient1 = 1,
        Ingredient2 = 1,
        Ingredient3 = 1
    },

    [2] = {
        Name = "Grr",
        Ingredient1 = 2,
        Ingredient2 = 3,
        Ingredient3 = 4
    },

    [3] = {
        Name = "Eberts Explosive Event",
        Ingredient1 = 8,
        Ingredient2 = 12,
        Ingredient3 = 16
    }
    
}

RecipeList.RecipeListInit = function()

end

------- This is a debugging tool to check for equivalency of recipes -------
------- pretty ineffecient, so rely on strictly for debugging :)     -------
RecipeList.CheckForRecipeConflicts = function()
    for recipe1Index = 1, #RecipeList do
        for recipe2Index = recipe1Index + 1, #RecipeList do
            print("in here")
            local recipe1 = RecipeList[recipe1Index]
            local recipe2 = RecipeList[recipe2Index]

            local recipe1Multiplier
            local recipe2Multiplier

            if recipe1["Ingredient3"] ~= 0 and recipe2["Ingredient3"] ~= 0 then
                
            elseif recipe1["Ingrdeint2"] ~= 0 and recipe2["Ingredient2"] ~= 0 then

            elseif recipe1["Ingrdeint3"] ~= 0 and recipe2["Ingredient3"] ~= 0 then
                
            end


            if recipe1Multiplier * recipe1["Ingredient1"] == recipe2Multiplier * recipe2["Ingredient1"] and
               recipe1Multiplier * recipe1["Ingredient2"] == recipe2Multiplier * recipe2["Ingredient2"] then
                print("WARNING: " .. recipe1["Name"] .. " HAS THE SAME RATIO OF INGREDIENTS AS " .. recipe2["Name"])
            end
        end
    end
end

return RecipeList