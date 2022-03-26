local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts.PotionCreation:WaitForChild("PotionUtilities"))
local Timer = require(ServerScriptService.Utilities:WaitForChild("Timer"))

local INGREDIENT_1_NAME = "Ingredient1"
local INGREDIENT_2_NAME = "Ingredient2"
local INGREDIENT_3_NAME = "Ingredient3"

local INGREDIENT_1_NODE_NAME = "Ingredient1Spawn"
local INGREDIENT_2_NODE_NAME = "Ingredient2Spawn"
local INGREDIENT_3_NODE_NAME = "Ingredient3Spawn"

local Ingredient1ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient1")
local Ingredient2ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient2")
local Ingredient3ServerPart = ServerStorage.Island_3.ingredients.spawns:WaitForChild("Ingredient3")

local IngredientSpawnUtilities = {}

local ingredientSpawns = {}

local function SpawnCoroutineTask(node)
    while true do
        local IngredientInstance = node["block"]:Clone()
        IngredientInstance.Parent = node["nodePart"]
        IngredientInstance.Position = IngredientInstance.Parent.Position
        IngredientInstance.Orientation = IngredientInstance.Parent.Orientation

        IngredientInstance.Touched:Connect(function(objectHit)
            if IngredientInstance.Name == INGREDIENT_1_NAME then
                PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            elseif IngredientInstance.Name  == INGREDIENT_2_NAME then
                PotionUtilities.IncrementIngredient2(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            elseif IngredientInstance.Name == INGREDIENT_3_NAME then
                PotionUtilities.IncrementIngredient3(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            end

            IngredientInstance:Destroy()

            local nextSpawn = math.random(3, 10)

            local timer = Timer.new()
            timer:start(nextSpawn, nil)
            timer.finished:Connect(function()
                coroutine.resume(node["spawnCoroutine"], node)
            end)
        end)
        coroutine.yield()
    end
end

IngredientSpawnUtilities.initialize = function()
    for index, nodePart in pairs(Workspace.Island_3.Islands.IngredientSpawnNodes:GetChildren()) do
        local tempBlock
        if nodePart.Name == INGREDIENT_1_NODE_NAME then
            tempBlock = Ingredient1ServerPart
        elseif nodePart.Name == INGREDIENT_2_NODE_NAME then
            tempBlock = Ingredient2ServerPart
        elseif nodePart.Name == INGREDIENT_3_NODE_NAME then
            tempBlock = Ingredient3ServerPart
        end
        ingredientSpawns[index] = {
            spawnCoroutine = coroutine.create(SpawnCoroutineTask),
            block = tempBlock,
            nodePart = nodePart
        }
        coroutine.resume(ingredientSpawns[index]["spawnCoroutine"], ingredientSpawns[index])
    end
end

return IngredientSpawnUtilities