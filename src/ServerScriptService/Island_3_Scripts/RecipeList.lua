local RecipeList = {
    [1] = {
        Name = "Butt",
        Ingredient1 = 0,
        Ingredient2 = 0,
        Ingredient3 = 2
    },

    [2] = {
        Name = "Grr",
        Ingredient1 = 0,
        Ingredient2 = 0,
        Ingredient3 = 16
    },

    [3] = {
        Name = "Eberts Explosive Event",
        Ingredient1 = 2,
        Ingredient2 = 0,
        Ingredient3 = 14
    }
    --explosion, grow, shrink
}

RecipeList.RecipeListInit = function()

end

------- This is a debugging tool to check for equivalency of recipes -------
------- pretty ineffecient, so rely on strictly for debugging :)     -------
RecipeList.CheckForRecipeConflicts = function()
    for recipe1Index = 1, #RecipeList do
        for recipe2Index = recipe1Index + 1, #RecipeList do

            local Ingredient1Equivalent = false
            local Ingredient2Equivalent = false
            local Ingredient3Equivalent = false

            local recipe1 = RecipeList[recipe1Index]
            local recipe2 = RecipeList[recipe2Index]
            --print(recipe1["Ingredient1"])
            --print(recipe2)

            -- take the higher number of the two recipes Ingredient 1 and mod them to see if there is a remainder
            if recipe1["Ingredient1"] > recipe2["Ingredient1"] then
                if recipe1["Ingredient1"] % recipe2["Ingredient1"] == 0 then
                    Ingredient1Equivalent = true
                end
            elseif recipe1["Ingredient1"] < recipe2["Ingredient1"] then
                if recipe2["Ingredient1"] % recipe1["Ingredient1"] == 0 then
                    Ingredient1Equivalent = true
                end 
            -- this else runs if there is equivalency on both
            else
                Ingredient1Equivalent = true  
            end

            -- same thing for ingredient 2
            if recipe1["Ingredient2"] > recipe2["Ingredient2"] then
                if recipe1["Ingredient2"] % recipe2["Ingredient2"] == 0 then
                    Ingredient2Equivalent = true
                end
            elseif recipe1["Ingredient2"] < recipe2["Ingredient2"] then
                if recipe2["Ingredient2"] % recipe1["Ingredient2"] == 0 then
                    Ingredient2Equivalent = true
                end
            else
                Ingredient2Equivalent = true  
            end

            -- same thing for ingredient 3
            if recipe1["Ingredient3"] > recipe2["Ingredient3"] then
                if recipe1["Ingredient3"] % recipe2["Ingredient3"] == 0 then
                    Ingredient3Equivalent = true
                end
            elseif recipe1["Ingredient3"] < recipe2["Ingredient3"] then
                if recipe2["Ingredient3"] % recipe1["Ingredient3"] == 0 then
                    Ingredient3Equivalent = true
                end
            else
                Ingredient2Equivalent = true  
            end
            
            print("Do Ingredients(1-3) Modulo: " .. recipe1["Name"] .. " and " .. recipe2["Name"] .. " -- " .. tostring(Ingredient1Equivalent) .. " , " .. tostring(Ingredient2Equivalent) .. " , " .. tostring(Ingredient3Equivalent))

            --Check if the modulos are equal to zero and continue
            if Ingredient1Equivalent and Ingredient2Equivalent and Ingredient3Equivalent then
                local ratio

                -- We need to create a ratio, so we need to make sure the ingredients aren't zero
                if recipe1["Ingredient1"] ~= 0 and recipe2["Ingredient1"] ~= 0 then
                    -- Create a ratio between recipe 1 and 2 using the first ingredient
                    ratio = recipe2["Ingredient1"]/recipe1["Ingredient1"]

                    -- Check to see if the other ingredients follow the same ratio between recipe 1 and 2
                    if ratio * recipe1["Ingredient2"] == recipe2["Ingredient2"] and
                       ratio * recipe1["Ingredient3"] == recipe2["Ingredient3"] then
                        print("RECIPE WARNING: Used ratio " .. ratio .. " to determine that " .. recipe1["Name"] .. " and " .. recipe2["Name"] .. " are equivalent ratios")
                    end

                elseif recipe1["Ingrdeint2"] ~= 0 and recipe2["Ingredient2"] ~= 0 then
                    ratio = recipe2["Ingredient2"]/recipe1["Ingredient2"]

                    if ratio * recipe1["Ingredient3"] == recipe2["Ingredient3"] then
                        print("RECIPE WARNING: Used ratio " .. ratio .. " to determine that " .. recipe1["Name"] .. " and " .. recipe2["Name"] .. " are equivalent ratios")
                    end

                elseif recipe1["Ingrdeint3"] ~= 0 and recipe2["Ingredient3"] ~= 0 then
                    print("RECIPE WARNING: " .. recipe1["Name"] .. " and " .. recipe2["Name"] .. " are equivalent ratios")
                end
            end
        end
    end
end

return RecipeList