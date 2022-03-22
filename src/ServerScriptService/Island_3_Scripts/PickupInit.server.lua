local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local redIngredient = ServerStorage.Island_3.ingredients:WaitForChild("red")
local greenIngredient = ServerStorage.Island_3.ingredients:WaitForChild("green")
local blueIngredient = ServerStorage.Island_3.ingredients:WaitForChild("blue")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionUtilities"))

for _,part in pairs(workspace.Island_3.test_zone.ingredients:GetDescendants()) do
    if part:IsA("BasePart") then
        -- what happens for red block
        if part.Name == "red" then 
            part.Touched:Connect(function(objectHit)
                PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
                part:Destroy()
            end)
        end

        if part.Name == "blue" then 
            part.Touched:Connect(function(objectHit)
                PotionUtilities.IncrementIngredient2(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
                part:Destroy()
            end)
        end

        if part.Name == "green" then 
            part.Touched:Connect(function(objectHit)
                PotionUtilities.IncrementIngredient3(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
                part:Destroy()
            end)
        end
    end
end