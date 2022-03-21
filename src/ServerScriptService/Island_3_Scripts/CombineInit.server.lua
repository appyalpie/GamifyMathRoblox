local combineBlock = workspace.Island_3.test_zone:WaitForChild("combine_ingredients")
local playerIngredients = {}

local ServerStorage = game:GetService("ServerStorage")
local resultPotion = ServerStorage.Island_3.ingredients:WaitForChild("result")

local NUM_OF_RED_NEEDED = 3

combineBlock.Touched:Connect(function(objectHit)

    if objectHit.Parent:FindFirstChildWhichIsA("Humanoid") then
        local player = game.Players:GetPlayerFromCharacter(objectHit.Parent)
        local playerBackback = player:WaitForChild("Backpack")
        --local playerEquipped = game.Workspace:FindFirstChild(player.Name):FindFirstChildWhichIsA("Tool")
        local backpackContents = playerBackback:GetChildren()
        for _,backpackItem in pairs(backpackContents) do
            playerIngredients[backpackItem.Name] =
            {
                quantity = backpackItem:GetAttribute("quantity")
            }
        end
        --playerIngredients[playerEquipped.Name] =
        --{
        --    quantity = playerEquipped:GetAttribute("quantity")
        --}

        print(playerIngredients["red"]["quantity"])

        if playerIngredients["red"]["quantity"] >= NUM_OF_RED_NEEDED then
            local redClone = resultPotion:Clone()
            redClone.Parent = playerBackback
            playerIngredients["red"]["quantity"] = playerIngredients["red"]["quantity"] - NUM_OF_RED_NEEDED
        end
    end

end)