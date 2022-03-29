local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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

-- This coroutine loops infiunitely but yields after every loop waiting for the block it created to be touched to resume
local function SpawnCoroutineTask(node)
    while true do
        local IngredientInstance = node["block"]:Clone()
        IngredientInstance.Parent = node["nodePart"]
        IngredientInstance.Position = IngredientInstance.Parent.Position
        IngredientInstance.Orientation = IngredientInstance.Parent.Orientation

        -- Tween in like it's growing in
        local twinfo = TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out,0,false,0)
        local sizeTweenIn
        if IngredientInstance.Name == INGREDIENT_1_NAME then
            sizeTweenIn = TweenService:Create(IngredientInstance ,twinfo, {Size = Vector3.new(1.42, 1.475, 1.497)})
        elseif IngredientInstance.Name  == INGREDIENT_2_NAME then
            sizeTweenIn = TweenService:Create(IngredientInstance ,twinfo, {Size = Vector3.new(1.143, 1.143, 1.525)})
        elseif IngredientInstance.Name == INGREDIENT_3_NAME then
            sizeTweenIn = TweenService:Create(IngredientInstance.Mesh ,twinfo, {Scale = Vector3.new(0.65, 1.8, 0.7)})
        end

        sizeTweenIn:Play()

        IngredientInstance.Touched:Connect(function(objectHit)
            if IngredientInstance.Name == INGREDIENT_1_NAME then
                PotionUtilities.IncrementIngredient1(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            elseif IngredientInstance.Name  == INGREDIENT_2_NAME then
                PotionUtilities.IncrementIngredient2(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            elseif IngredientInstance.Name == INGREDIENT_3_NAME then
                PotionUtilities.IncrementIngredient3(game.Players:GetPlayerFromCharacter(objectHit.Parent), 1)
            end

            IngredientInstance:Destroy()

            --Create a timer waiting for the next spawn (random depending on ingredient)
            local nextSpawn
            if IngredientInstance.Name == INGREDIENT_1_NAME then
                nextSpawn = math.random(3, 10)
            elseif IngredientInstance.Name  == INGREDIENT_2_NAME then
                nextSpawn = math.random(25, 35)
            elseif IngredientInstance.Name == INGREDIENT_3_NAME then
                nextSpawn = math.random(3, 10)
            end


            local timer = Timer.new()
            timer:start(nextSpawn, nil)
            --once the timer finishes, the coroutine calls itself again
            timer.finished:Connect(function()
                coroutine.resume(node["spawnCoroutine"], node)
            end)
        end)
        coroutine.yield()
    end
end

--Initialize the coroutine for every spawn node
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