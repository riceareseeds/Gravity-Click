local badgeH = {}

badgeH.Event = ScriptService.AwardBadgeEvent

badgeH.CreatorID = 414490

badgeH.badges = {
	["Welcome"] = 210728,
	["Meet Creator"] = 210730,
	["Defeat Queen Teto"] = 210729,
	["Collectathon"] = 211745,
	["Lie"] = 212881,
	["COOKIE"] = 212882,
	["Oh No"] = 212883
}

local function plrExisting(plr)
	return (plr and plr.UserID and plr.Name)
end

function badgeH.playerAward(badgeName, plr)
	local plrName = plr.Name
	local plrID = plr.UserID
	if not Achievements.HasAchievementAsync(plrID, badgeH.badges[badgeName]) then
		Achievements.AwardAsync(plrID, badgeH.badges[badgeName])
		Chat.BroadcastMessage(plrName.." Has Been Awarded The "..badgeName.." Badge!")
	else
		print(plrName.." already has badge "..badgeName..".")
	end
end

function badgeH.globalAward(badgeName)
	for _, plr in Players:GetPlayers() do
		if not plrExisting(plr) then continue end
		badgeH.playerAward(badgeName, plr)
	end
end

function badgeH.init()
	print("Initializing "..script.Name.."...")
	Players.PlayerAdded:Connect(function(plr)
		badgeH.playerAward("Welcome", plr)
		if plr.UserID == badgeH.CreatorID then
			badgeH.globalAward("Meet Creator")
		elseif Players.GetPlayerByID(badgeH.CreatorID) then
			badgeH.playerAward("Meet Creator", plr)
		end
		local Collectables = Stats.WaitChild("Collectables")
		local goal = 100
		Collectables.Set(plr, 0)
		repeat wait(0.5) until Collectables.Get(plr)
		repeat wait(0.5) until (Collectables.Get(plr) >= goal) or not plr
		if (Collectables.Get(plr) >= goal) then badgeH.playerAward("Collectathon", plr) end
	end)
	badgeH.globalAward("Welcome")
	badgeH.Event.InvokedServer:Connect(function(plr, msg)
    local badgeName = msg.GetString("badgeName")
    if not badgeH.badges[badgeName] then
      print("Unknown badge: "..badgeName)
      return
    end
    badgeH.playerAward(badgeName, plr)
	end)
	print(script.Name.." Initialized!")
end

return badgeH