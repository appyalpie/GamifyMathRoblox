local disabled = true
if disabled then
    return
end

local LeaderBoardGUI = game.Workspace.Main_Hub_Enclave.LeaderBoard.SurfaceGui.Board
local Players = game:GetService("Players")
local UpdateLeaderBoardRE = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents"):FindFirstChild("UpdateLeaderBoardRE")

local function UpdateClientLeaderBoard(LeaderBoardTable)
    LeaderBoardGUI = ""
      for _,v in pairs(LeaderBoardTable) do
            for k,d in pairs(v) do
                LeaderBoardGUI.Text = LeaderBoardGUI.Text .. Players:GetNameFromUserIdAsync(k) .. " - " ..  d .. "\n"
            end
      end
end



UpdateLeaderBoardRE.onClientEvent:Connect(UpdateClientLeaderBoard)