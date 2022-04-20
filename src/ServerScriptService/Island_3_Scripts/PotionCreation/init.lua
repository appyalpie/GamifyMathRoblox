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

local ResetIngredientsBE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ResetIngredientsEvent")

local PotionPromptActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("PotionPromptActivatedEvent")
local CombinationButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombinationButtonActivatedEvent")
local MissingIngredientRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("MissingIngredientsEvent")
local InvalidRecipeRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("InvalidRecipeEvent")
local CombineMenuFinishedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("CombineMenuFinishedEvent")
local ExitButtonActivatedRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ExitButtonActivatedEvent")
local PlayerExitCombinationServerRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("PlayerExitCombinationServerEvent")
local DisableCombinationButtonRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("DisableCombinationButtonEvent")
local AddTextToRecipeReferenceRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("AddTextToRecipeReferenceEvent")

local PotionUtilities = require(ServerScriptService.Island_3_Scripts.PotionCreation:WaitForChild("PotionUtilities"))
local RecipeList = require(ServerScriptService.Island_3_Scripts:WaitForChild("RecipeList"))
local GameStatsUtilities = require(ServerScriptService.GameStatsInitialization.GameStatsUtilities)

local POTION_COMBINATION_XP_REWARD = 20
local POTION_COMBINATION_CURRENCY_REWARD = 5

PotionCreation = {}

local combinationTables = {}

local function cleanup(player, combinationTableID)
    local combinationTable = combinationTables[combinationTableID]
    local beakerSmokeEffect = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Smoke")
    local beakerTameBits = combinationTable.Beaker.MagicSmoke.Core:WaitForChild("Bits")
    local promptObject = combinationTable.Beaker.Beaker.PromptAttachment:WaitForChild("ProximityPrompt")

    promptObject.Enabled = true
    beakerSmokeEffect.Enabled = false
    beakerTameBits.Enabled = false

    UnlockMovementRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)
    CameraResetRE:FireClient(player)
    CombineMenuFinishedRE:FireClient(player)
end

-- Initialize combination tables so the correct effects play on the proper tables
function PotionCreation.initializeCombinationTables()
    for _, tableObject in pairs(game.Workspace.Island_3.Islands.PotionCreationTables:GetChildren()) do
        combinationTables[tableObject:GetAttribute("ID")] = tableObject
    end
end

-- Initialize potion creation, called when the prompt for potion creation is activated
function PotionCreation.initialize(player, promptObject)
    -- get all the camera/player lock objects for potion creation
    local combinationTableID = promptObject.Parent.Parent.Parent.Parent:GetAttribute("ID")
    local combinationTable = combinationTables[combinationTableID]
    local lockObject = combinationTable.Table:WaitForChild("PlayerLockLocation")
    local cameraObject = combinationTable.Table:WaitForChild("TableCameraLocation")

    local beakerSmokeEffect = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Smoke")
    local beakerTameBits = combinationTable.Beaker.MagicSmoke.Core:WaitForChild("Bits")

    
    -- Move the player to the lock position
    --player.Character:WaitForChild("HumanoidRootPart").Position = lockObject.Position
    player.character:SetPrimaryPartCFrame(CFrame.new(lockObject.Position))

    -- Disable the prompt so other players cannot trigger the same interaction
    promptObject.Enabled = false;

    beakerSmokeEffect.Enabled = true
    beakerTameBits.Enabled = true

    -- Enable to check for recipe conflicts when the prompt is hit
    --RecipeList.CheckForRecipeConflicts()

    -- Move the camera, do UI things, hide the players title, and lock players movement
    CameraMoveToRE:FireClient(player, cameraObject, 1)
    PotionPromptActivatedRE:FireClient(player, combinationTableID)
    player.Character:PivotTo(lockObject:GetPivot())
    LockMovementRE:FireClient(player)
    PlayerSideHideNameAndTitleRE:FireClient(player)

    -- Error handling in case player disconnects
    local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		cleanup(player, combinationTableID)
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
            cleanup(player, combinationTableID)
			playerLeaveConnection:Disconnect()
		end
	end)

end


-- TODO: only one reward object in players backpack
local function onCombinationButtonActivated(player, selectedIngredients, combinationTableID)
    local playerIngredients = PotionUtilities.GetPlayerIngredients(player)

    local combinationTable = combinationTables[combinationTableID]

    local bubblingSound = combinationTable.Beaker.Beaker:WaitForChild("Bubbling")
    local recievePotionSound = combinationTable.Beaker.Beaker:WaitForChild("RecievePotion")
    local steamSound = combinationTable.Beaker.Beaker:WaitForChild("Steam")
    local beakerBitsFlyingUp = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Bits")
    local beakerExplosionSmoke = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("OutSmoke")
    local beakerSmokeEffect = combinationTable.Beaker.MagicSmoke.Attachment:WaitForChild("Smoke")
    local beakerTameBits = combinationTable.Beaker.MagicSmoke.Core:WaitForChild("Bits")

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

                    DisableCombinationButtonRE:FireClient(player)

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

                    -- Increment XP and Currency, play VFX for them too.
                    local character = player.Character or player.CharacterAdded:Wait()
                    local hrp = character:WaitForChild("HumanoidRootPart")
                    GameStatsUtilities.incrementXP(player, POTION_COMBINATION_XP_REWARD)
                    GameStatsUtilities.incrementCurrency(player, POTION_COMBINATION_CURRENCY_REWARD)
                    GameStatsUtilities.XPandCurrencyIncrementVFX(POTION_COMBINATION_XP_REWARD, POTION_COMBINATION_CURRENCY_REWARD, 
                                                                    hrp.Position, hrp.Orientation.Y)

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

local function PlayerExitCombinationServer(player, combinationTableID)
    combinationTables[combinationTableID].Beaker.Beaker.PromptAttachment:WaitForChild("ProximityPrompt").Enabled = true;
end

PlayerExitCombinationServerRE.OnServerEvent:Connect(PlayerExitCombinationServer)

local function onExitButtonActivatedEvent(player, combinationTableID)
    cleanup(player, combinationTableID)
    CombineMenuFinishedRE:FireClient(player)
end

ExitButtonActivatedRE.OnServerEvent:Connect(onExitButtonActivatedEvent)


local function onResetIngredientsEvent(player)
    PotionUtilities.InitializePlayerIngredientInventory(player)
end

ResetIngredientsBE.Event:Connect(onResetIngredientsEvent)

return PotionCreation