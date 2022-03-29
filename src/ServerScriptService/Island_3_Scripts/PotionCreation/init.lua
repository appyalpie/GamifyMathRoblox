local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
local InvalidRecipeRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("InvalidRecipeEvent")
local CombineMenuFinishedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombineMenuFinishedEvent")
local ExitButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ExitButtonActivatedEvent")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts.PotionCreation:WaitForChild("PotionUtilities"))
local RecipeList = require(ServerScriptService.Island_3_Scripts:WaitForChild("RecipeList"))

local AddTextToRecipeReferenceRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("AddTextToRecipeReferenceEvent")

local beakerSmokeEffect
local beakerBitsFlyingUp
local beakerExplosionSmoke
local beakerTameBits
local bubblingSound
local recievePotionSound
local steamSound

local potionPrompt

PotionCreation = {}

-- Initialize potion creation, called when the prompt for potion creation is activated
function PotionCreation.initialize(player, promptObject)
    -- get all the camer/player lock objects for potion creation
    local combinationTable = promptObject.Parent.Parent.Parent.Parent
    local lockObject = combinationTable.Table:WaitForChild("PlayerLockLocation")
    local cameraObject = combinationTable.Table:WaitForChild("TableCameraLocation")
    bubblingSound = combinationTable.Beaker.Beaker:WaitForChild("Bubbling")
    recievePotionSound = combinationTable.Beaker.Beaker:WaitForChild("RecievePotion")
    steamSound = combinationTable.Beaker.Beaker:WaitForChild("Steam")
    beakerSmokeEffect = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Smoke")
    beakerBitsFlyingUp = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Bits")
    beakerExplosionSmoke = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("OutSmoke")
    beakerTameBits = combinationTable.Beaker.MagicSmoke.Core:WaitForChild("Bits")

    -- Move the player to the lock position
    player.Character:WaitForChild("HumanoidRootPart").Position = lockObject.Position

    -- Disable the prompt so other players cannot trigger the same interaction
    potionPrompt = promptObject
    promptObject.Enabled = false;

    beakerSmokeEffect.Enabled = true
    beakerTameBits.Enabled = true

    -- Enable to check for recipe conflicts when the prompt is hit
    --RecipeList.CheckForRecipeConflicts()

    -- Move the camera, do UI things, hide the players title, and lock players movement
    CameraMoveToRE:FireClient(player, cameraObject, 1)
    PotionPromptActivatedRE:FireClient(player)
    player.Character:PivotTo(lockObject:GetPivot())
    LockMovementRE:FireClient(player)
    PlayerSideHideNameAndTitleRE:FireClient(player)

    -- Error handling in case player disconnects
    local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		potionPrompt.Enabled = true
        beakerSmokeEffect.Enabled = false
        beakerTameBits.Enabled = false
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			potionPrompt.Enabled = true
            beakerSmokeEffect.Enabled = false
            beakerTameBits.Enabled = false
			playerLeaveConnection:Disconnect()
		end
	end)

end

-- TODO: only one reward object in players backpack
local function onCombinationButtonActivated(player, selectedIngredients)
    local playerIngredients = PotionUtilities.GetPlayerIngredients(player)


    -- Compare selectedIngredients to Player's amount of ingredients
    if selectedIngredients["Ingredient1"] <= playerIngredients["Ingredient1"] and
       selectedIngredients["Ingredient2"] <= playerIngredients["Ingredient2"] and
       selectedIngredients["Ingredient3"] <= playerIngredients["Ingredient3"] then
        
        --Get all the recipes and check for equivalency
        for _, recipe in pairs(RecipeList) do 
            if type(recipe) == "table" then
                local returnedValue = RecipeList.CheckForEquivalency(selectedIngredients, recipe)
                -- If it returns a recipe, we found an equivalent one
                if returnedValue ~= nil then
                    PotionUtilities.DecrementIngredients(player, selectedIngredients)
                    local rewardObject = returnedValue["RewardObject"]:Clone()

                    bubblingSound:Play()
                    beakerBitsFlyingUp.Enabled = true

                    wait(1.75)

                    steamSound:Play()
                    beakerExplosionSmoke.Enabled = true

                    wait(2)

                    recievePotionSound:Play()

                    beakerSmokeEffect.Enabled = false
                    beakerBitsFlyingUp.Enabled = false
                    beakerExplosionSmoke.Enabled = false
                    beakerTameBits.Enabled = false

                    -- Add the discovered recipe to the recipe reference paper
                    AddTextToRecipeReferenceRE:FireClient(player, recipe)

                    -- This line of code assigns the reward object to the players backpack
                    -- There is no controlling if it is in your inventory more then once atm
                    rewardObject.Parent = player:WaitForChild("Backpack")

                    --Unlock player, show titles, and reset camera
                    UnlockMovementRE:FireClient(player)
                    PlayerSideShowNameAndTitleRE:FireClient(player)
                    CameraResetRE:FireClient(player)
                
                    --do UI things
                    CombineMenuFinishedRE:FireClient(player)
                    wait(1)
                    -- Re-enable the prompt so others may interact with the table
                    potionPrompt.Enabled = true;
                    return
                end
            end
        end
    else
        MissingIngredientRE:FireClient(player)
        return
    end

    InvalidRecipeRE:FireClient(player)

end

CombinationButtonActivatedRE.OnServerEvent:Connect(onCombinationButtonActivated)

local function onExitButtonActivatedEvent(player)
    UnlockMovementRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)
    CameraResetRE:FireClient(player)

    beakerSmokeEffect.Enabled = false
    CombineMenuFinishedRE:FireClient(player)
    wait(1)
    potionPrompt.Enabled = true;
end

ExitButtonActivatedRE.OnServerEvent:Connect(onExitButtonActivatedEvent)



return PotionCreation