--local LeaderBoardGUI = game.Workspace.something
local UpdateLeaderBoardRE = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents"):FindFirstChild("UpdateLeaderBoardRE")

local function UpdateClientLeaderBoard(LeaderBoardTable)
    --LeaderBoardGUI.TextStorage.Text = ""
    local x = 0
    print(LeaderBoardTable)
     --[[   for i,v in pairs(LeaderBoardTable) do
            
            if player then
                player = Players:GetNameFromUserIdAsync(v.value)
            end
                -- convert each item to a row
                LeaderBoardGUI.TextStorage.Text = -- Name .. "  " .. Level .. "\n"
                
        end]]
end

UpdateLeaderBoardRE.onClientEvent:Connect(UpdateClientLeaderBoard)