local oOBRM = {}

local map = script.Parent.Parent

oOBRM._Floor = map.WaitChild("Floor")
oOBRM._Ceiling = map.WaitChild("Ceiling")
oOBRM._Spawn = map.WaitChild("Spawn")
oOBRM._AwardEvent = ScriptService.WaitChild("AwardBadgeEvent")
oOBRM._plr = Players.LocalPlayer
oOBRM._spawnPosition = oOBRM._Spawn.Position

local function touch(hit)
	if hit.Name == oOBRM._plr.Name then
		hit.Position = oOBRM._spawnPosition
		local msg = NetMessage.New()
		msg.AddString("badgeName", "Oh No")
		oOBRM._AwardEvent.InvokeServer(msg)
	end
end

function oOBRM.init()
	oOBRM._Floor.Touched:Connect(touch)
	oOBRM._Ceiling.Touched:Connect(touch)
end

return oOBRM