local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")

local PlayerSideHideNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideHideNameAndTitleEvent")
local PlayerSideShowNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideShowNameAndTitleEvent")

local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

local PotionPromptActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("PotionPromptActivatedEvent")
local CombinationButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombinationButtonActivatedEvent")
local MissingIngredientRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("MissingIngredientsEvent")

local lockObject = game.Workspace.Island_3.test_zone.Table:WaitForChild("PlayerLockLocation")
local cameraObject = game.Workspace.Island_3.test_zone.Table:WaitForChild("TableCameraLocation")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts:WaitForChild("PotionUtilities"))
local RecipeList = require(ServerScriptService.Island_3_Scripts:WaitForChild("RecipeList"))

local TABLE_OFFSET = Vector3.new(3.5, 1.5, -3.5)

PotionCreation = {}

function PotionCreation.initialize(player, promptObject)
    player.Character:WaitForChild("HumanoidRootPart").Position = lockObject.Position

    promptObject.Enabled = false;

    RecipeList.CheckForRecipeConflicts()

    CameraMoveToRE:FireClient(player, cameraObject, 1)
    PotionPromptActivatedRE:FireClient(player)
    player.Character:PivotTo(lockObject:GetPivot())
    LockMovementRE:FireClient(player)
    PlayerSideHideNameAndTitleRE:FireClient(player)

    wait(5)

    UnlockMovementRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)
    CameraResetRE:FireClient(player)

    promptObject.Enabled = true;
end

local function onCombinationButtonActivated(player, selectedIngredients)
    local playerIngredients = PotionUtilities.GetPlayerIngredients(player)

    -- Compare selectedIngredients to Player's amount of ingredients
    if selectedIngredients["Ingredient1"] <= playerIngredients["Ingredient1"] and
       selectedIngredients["Ingredient2"] <= playerIngredients["Ingredient2"] and
       selectedIngredients["Ingredient3"] <= playerIngredients["Ingredient3"] then

        PotionUtilities.DecrementIngredients(player, selectedIngredients)

    else
        MissingIngredientRE:FireClient(player)
    end

    
end

CombinationButtonActivatedRE.OnServerEvent:Connect(onCombinationButtonActivated)

return PotionCreation