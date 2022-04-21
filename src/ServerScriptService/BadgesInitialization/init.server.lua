local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeService = game:GetService("BadgeService")

local BadgeInformation = require(ReplicatedStorage:WaitForChild("BadgeInformation"))

local UpdateBadgesRE = ReplicatedStorage.RemoteEvents.BadgeEvents:WaitForChild("UpdateBadgesRE")
local UpdateBadgesReadyRE = ReplicatedStorage.RemoteEvents.BadgeEvents:WaitForChild("UpdateBadgesReadyRE")

local AwardBadgeBE = script:WaitForChild("AwardBadgeBE")

local BadgesDataStore = DataStoreService:GetDataStore("BadgesDataStore")

--[[
    Note: Usage of BadgeService + BadgesDataStore is due to BadgeService request limitations

    Badge Keys (badge_key) (string)
    Row1:
        1. WelcomeBadge
        2. MathBlocksBadge
        3. ChallengerBadge
        4. WizardBadge
    Row2:
        1. BetaTesterBadge
]]

local PlayerBadgesTable = {}

------ Aware Badge Event (BindableEvent, server sided) ------
AwardBadgeBE.Event:Connect(function(player, badge_key)
    local badgeId = BadgeInformation[badge_key].badgeId

    -- Fetch Badge information
    local success, badgeInfo = pcall(function()
        return BadgeService:GetBadgeInfoAsync(badgeId)
    end)

    if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local success, result = pcall(function()
				return BadgeService:AwardBadge(player.UserId, badgeId)
			end)

            if success and result then
                print("Successfully got a badge!")
                table.insert(PlayerBadgesTable[player.UserId], badge_key)
                UpdateBadgesRE:FireClient(player, PlayerBadgesTable[player.UserId])
            end
			
			if not success then
				-- the AwardBadge function threw an error
				warn("Error while awarding badge:", result)
			elseif not result then
				-- the AwardBadge function did not award a badge
				warn("Failed to award badge.")
            end
		end
	else
		warn("Error while fetching badge info: " .. badgeInfo)
	end
end)

------ Restore Badges Data (w/o using multiple BadgeService Calls)
Players.PlayerAdded:Connect(function(player)
    local success, returnedValue = pcall(function()
        return BadgesDataStore:GetAsync(player.UserId)
    end)

    if success then
        if returnedValue == nil or type(returnedValue) ~= "table" then
            PlayerBadgesTable[player.UserId] = {}
        else
            PlayerBadgesTable[player.UserId] = returnedValue
        end
    else -- Possible datastore throttle error
        PlayerBadgesTable[player.UserId] = {}
    end

    AwardBadgeBE:Fire(player, "WelcomeBadge")
    AwardBadgeBE:Fire(player, "BetaTesterBadge")
end)

------ When Client is ready to update, update (handshake) ------
UpdateBadgesReadyRE.OnServerEvent:Connect(function(player)
    UpdateBadgesRE:FireClient(player, PlayerBadgesTable[player.UserId])
end)

------ Save Cached Badge Data on Leave ------
Players.PlayerRemoving:Connect(function(player)
    local playerData = PlayerBadgesTable[player.UserId]
    local success, errorMessage = pcall(function()
        BadgesDataStore:SetAsync(player.UserId, playerData)
    end)
    if not success then
        print(errorMessage)
    end
end)

