local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Ingredient1ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient1")
local Ingredient2ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient2")
local Ingredient3ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient3")

local Ingredient1SpawnNode = Workspace.Island_3.test_zone.ingredients:WaitForChild("Ingredient1Spawn")
local Ingredient2SpawnNode = Workspace.Island_3.test_zone.ingredients:WaitForChild("Ingredient2Spawn")
local Ingredient3SpawnNode = Workspace.Island_3.test_zone.ingredients:WaitForChild("Ingredient3Spawn")

--local PotionUtilities = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionUtilities"))
local IngredientSpawns = require(ServerScriptService.Island_3_Scripts:WaitForChild("IngredientSpawns"))

IngredientSpawns.Initialize()


--[[Ingredient1ServerPart.Touched:Connect(function(objectHit)
    PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
    Ingredient1ServerPart:Destroy()
end)

Ingredient2ServerPart.Touched:Connect(function(objectHit)
    PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
    Ingredient1ServerPart:Destroy()
end)

Ingredient3ServerPart.Touched:Connect(function(objectHit)
    PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
    Ingredient1ServerPart:Destroy()
end)

while(true) do
    if not Ingredient1SpawnNode:FindFirstChildWhichIsA("Part") then
        print("in the if")
        local Ingredient1Clone = Ingredient1ServerPart:Clone()
        Ingredient1Clone.Parent = Ingredient1SpawnNode
        Ingredient1Clone.Touched:Connect(function(objectHit)
            PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            Ingredient1Clone:Destroy()
        end)
    end
end]]--


