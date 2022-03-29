local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RecipeReferenceViewRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("RecipeReferenceViewEvent")
local ExitRecipeReferenceViewRE = ReplicatedStorage.RemoteEvents.Island_3:WaitForChild("ExitRecipeReferenceViewEvent")

local CameraMoveToRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraMoveToRE")
local CameraResetRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraResetRE")
local CameraSetFOVRE = ReplicatedStorage.RemoteEvents.CameraUtilRE:WaitForChild("CameraSetFOVRE")

local LockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("LockMovementRE")
local UnlockMovementRE = ReplicatedStorage.RemoteEvents:WaitForChild("UnlockMovementRE")

local PlayerSideHideNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideHideNameAndTitleEvent")
local PlayerSideShowNameAndTitleRE = ReplicatedStorage.RemoteEvents.Titles:WaitForChild("PlayerSideShowNameAndTitleEvent")

local recipeViewPrompt
RecipeReference = {}

RecipeReference.Initialize = function(player, combinationTable)
    local newCamera = combinationTable.Paper.SurfaceGuiPart.PaperCameraLocation
    recipeViewPrompt = combinationTable.PaperHolder.PromptAttachment.ProximityPrompt
    recipeViewPrompt.Enabled = false
    CameraMoveToRE:FireClient(player, newCamera, 1)
    PlayerSideHideNameAndTitleRE:FireClient(player)
    LockMovementRE:FireClient(player)
    RecipeReferenceViewRE:FireClient(player)

    local playerHumanoidDiedConnection
	playerHumanoidDiedConnection = player.Character:WaitForChild("Humanoid").Died:Connect(function()
		recipeViewPrompt.Enabled = true;
		playerHumanoidDiedConnection:Disconnect()
	end)
	local playerLeaveConnection
	playerLeaveConnection = Players.PlayerRemoving:Connect(function(removed)
		if removed == player then
			recipeViewPrompt.Enabled = true;
			playerLeaveConnection:Disconnect()
		end
	end)
end

------- when exit button is hit -------
local function onRecipeReferenceExitButtonActivatedEvent(player)
    UnlockMovementRE:FireClient(player)
    PlayerSideShowNameAndTitleRE:FireClient(player)
    CameraResetRE:FireClient(player)

    wait(1)
    recipeViewPrompt.Enabled = true;
end

ExitRecipeReferenceViewRE.OnServerEvent:Connect(onRecipeReferenceExitButtonActivatedEvent)


return RecipeReference