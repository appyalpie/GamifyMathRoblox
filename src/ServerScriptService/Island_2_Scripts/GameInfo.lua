local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")

local Game_24_Folder = ServerStorage.Island_2.Game_24

local GameInfo = {}

GameInfo.ORIGIN_POSITION_OFFSET = 9
GameInfo.MOVE_POSITION_OFFSET = 3

GameInfo.PositionTweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

GameInfo.CombineTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

GameInfo.DestroySplitTweenInfo = TweenInfo.new(.5)

GameInfo.MoveSplitTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

GameInfo.SplitCardTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

GameInfo.LookUpTable = {
    ["+"] = Game_24_Folder.Numbers:WaitForChild("Add"),
    ["-"] = Game_24_Folder.Numbers:WaitForChild("Subtract"),
    ["x"] = Game_24_Folder.Numbers:WaitForChild("Multiply"),
    ["/"] = Game_24_Folder.Numbers:WaitForChild("Divide"),
    ["("] = Game_24_Folder.Numbers:WaitForChild("LeftParenthesis"),
    [")"] = Game_24_Folder.Numbers:WaitForChild("RightParenthesis"),
    [" "] = Game_24_Folder.Numbers:WaitForChild("Space")
}

GameInfo.WinningCardBeamTexture = "http://www.roblox.com/asset/?id=446111271"

GameInfo.BoardCardTweenInfo = TweenInfo.new(3)

GameInfo.WinningCardTweenInfo = TweenInfo.new(3)
GameInfo.WinningCardOffsetGoal = Vector3.new(0, 10, 0)
GameInfo.WinningSequenceOffsetGoal = Vector3.new(0, 5, 0)

GameInfo.WinningSequenceTweenInfo = TweenInfo.new(.4)
GameInfo.WinningSequenceSqueezeTweenInfo = TweenInfo.new(.4)
GameInfo.WinningSequenceEnergyBallTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

GameInfo.SelectTweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

GameInfo.OperatorNames = {
    ["+"] = "add",
    ["-"] = "subtract",
    ["x"] = "multiply",
    ["/"] = "divide"
}

GameInfo.CameraXZOffset = 6
GameInfo.CameraYOffset = 6.5
GameInfo.InitialCameraMoveTime = 2
GameInfo.CameraMoveTime = .4
GameInfo.FOVSetTime = 1.5
GameInfo.FOV = 85
GameInfo.FOVWinning = 105

GameInfo.NPCXPTable = {
    easy = 15,
    medium = 20,
    hard = 25
}

GameInfo.NPCCurrencyTable = {
    easy = 15,
    medium = 20,
    hard = 25
}

GameInfo.SinglePlayerXPTable = {
    easy = 10,
    medium = 15,
    hard = 20
}

GameInfo.SinglePlayerCurrencyTable = {
    easy = 10,
    medium = 15,
    hard = 20
}

--GameInfo.CombineYDirectionTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
--GameInfo.CombineXZDirectionTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In)

return GameInfo